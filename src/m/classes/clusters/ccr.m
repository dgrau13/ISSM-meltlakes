%CCR cluster class definition
%
%   Usage:
%      cluster=ccr();
%      cluster=ccr('np',3);
%      cluster=ccr('np',3,'login','username');

classdef ccr
	properties (SetAccess=public)
		% {{{
		name           = oshostname()
		login          = 'dgrau@vortex.ccr.buffalo.edu';
		port           = 0;
		cluster        = 'ub-hpc';% or faculty 
		partition      = 'general-compute';
		qos 	       = 'general-compute';
		account        = '';
		time           = 1*3600; %hr
		numnodes       = 1; %number of nodes
		ntasks	       = 1; %number of tasks per node
		cpuspertask    = 1;%number of cpus per task
        exclusive      = false;
		mem 	       = 1*1000; %GB
		jobname	       = '';
		modules        = {'ccrsoft/2023.01' 'cmake/3.22.1' 'matlab/2023b' 'gcc/11.2.0'};
		srcpath        = '/user/dgrau/ISSM-meltlakes';
		codepath       = '/user/dgrau/ISSM-meltlakes/bin';
		executionpath  = '/user/dgrau/ISSM-meltlakes/execution';
		interactive    = 0;
		bbftp          = 0;
        email          = '';
	end
	%}}}
	methods
		function cluster=ccr(varargin) % {{{

			%initialize cluster using default settings if provided
			if (exist('ccr_settings')==2), ccr_settings; end

			%use provided options to change fields
			cluster=AssignObjectFields(pairoptions(varargin{:}),cluster);
		end
		%}}}
		function disp(cluster) % {{{
			% display the object
			disp(sprintf('class ''%s'' object ''%s'' = ',class(cluster),inputname(1)));
			disp(sprintf('    name: %s',cluster.name));
			disp(sprintf('    login: %s',cluster.login));
			disp(sprintf('    port: %i',cluster.port));
			disp(sprintf('	  cluster: %s',cluster.cluster));
			disp(sprintf('	  partition: %s', cluster.partition));
			disp(sprintf('    queue: %s',cluster.qos));
			disp(sprintf('    account: %s',cluster.account));
			disp(sprintf('    time: %i',cluster.time));
			disp(sprintf('    numnodes: %i',cluster.numnodes));
			disp(sprintf('	  ntasks: %i',cluster.ntasks));
			disp(sprintf('    cpuspertask: %i',cluster.cpuspertask));
			disp(sprintf('	  memory: %i',cluster.mem));
			disp(sprintf('    jobname: %s',cluster.jobname));
			disp(sprintf('    modules: %s',strjoin(cluster.modules,', ')));
			disp(sprintf('    srcpath: %s',cluster.srcpath));
			disp(sprintf('    codepath: %s',cluster.codepath));
			disp(sprintf('    executionpath: %s',cluster.executionpath));
			disp(sprintf('    interactive: %i',cluster.interactive));
			disp(sprintf('    bbftp: %s',cluster.bbftp));
		end
		%}}}
		function numprocs=nprocs(cluster) % {{{
			%compute number of processors
			numprocs=cluster.numnodes*cluster.cpuspertask;
		end
		%}}}
		function md = checkconsistency(cluster,md,solution,analyses) % {{{
			if strcmpi(cluster.cluster,'ub_hpc')
				if cluster.qos ~= cluster.partition
					if ~ismember(cluster.qos,{'supporters','mri','nih'})
						md = md.checkmessage('Value of qos should either match value of partition or be set to "supporters", "mri", or "nih"');
					end
				end

				available_queues={'debug','general-compute','industry','scavenger','viz','faculty'};
				queue_requirements_time=[1*3600 72*3600 6*3600 6*3600 24*3600 72*3600];
				queue_requirements_np=[64 64 56 64 64 64];

			QueueRequirements(available_queues,queue_requirements_time,queue_requirements_np,cluster.partition,cluster.nprocs(),cluster.time)
            elseif strcmpi(cluster.cluster,'faculty')
				if strcmpi(cluster.account,'')
					md = md.checkmessage('please supply valid account when using the faculty cluster');
				end
				if strcmpi(cluster.partition,'sophien')==0 & strcmpi(cluster.qos,'sophien')==0 & strcmpi(cluster.account,sophien')==0
					md = md.checkmessage('combination of partition and qos and account invalid');
				end
			else
				md = md.checkmessage('invalid value for cluster');
			end

			%Miscellaneous
			if isempty(cluster.srcpath), md = checkmessage(md,'srcpath empty'); end
			if isempty(cluster.codepath), md = checkmessage(md,'codepath empty'); end
			if isempty(cluster.executionpath), md = checkmessage(md,'executionpath empty'); end

		end
		%}}}
		function BuildQueueScript(cluster, md, filename, executable) % {{{

			%Get variables from md
			dirname    = md.private.runtimename;
			modelname  = md.miscellaneous.name;
			solution   = md.private.solution;
			io_gather  = md.settings.io_gather;
			isvalgrind = md.debug.valgrind;

			%checks
			if(md.debug.gprof) 
                disp('gprof not supported by cluster, ignoring...'); 
            end

			%write queuing script
			fid=fopen(filename, 'w');

			fprintf(fid,'#!/bin/bash -l\n');
			fprintf(fid,'#SBATCH --time=%i\n',cluster.time*3600); %walltime is in seconds now converted to hours
			fprintf(fid,'#SBATCH --ntasks=%i\n', cluster.ntasks);
			fprintf(fid,'#SBATCH --cpus-per-task=%i\n',cluster.cpuspertask);
			if strcmpi(cluster.cluster,'faculty')
				fprintf('#SBATCH --constraint="[SAPPHIRE-RAPIDS-IB|ICE-LAKE-IB|CASCADE-LAKE-IB|EMERALD-RAPIDS-IB]"\n');
			end
			fprint(fid,'#SBATCH --mem=%i\n',cluster.mem);
			fprintf(fid,'#SBATCH --qos=%s\n',cluster.qos);
			fprintf(fid,'#SBATCH --job-name=%s\n',cluster.jobname);
			fprintf(fid,'#SBATCH --output= %s/%s/%s.outlog \n',cluster.executionpath,dirname,modelname);
			fprintf(fid,'#SBATCH --error=%s/%s/%s.errlog \n\n',cluster.executionpath,dirname,modelname);
			fprintf(fid,'SBATCH --partition=%s\n',cluster.partition);
			fprintf(fid,'SBATCH --cluster=%s\n',cluster.cluster);
			if cluster.account ~= ''
				fprintf(fid,'#SBATCH --account=%s\n',cluster.account);
			end
			%fprintf(fid,'. /usr/share/modules/init/bash\n\n');
			for i=1:numel(cluster.modules), fprintf(fid,['module load ' cluster.modules{i} '\n']); end
			fprintf(fid,'export PATH="$PATH:."\n\n');
			fprintf(fid,'export ISSM_DIR="%s"\n',cluster.srcpath); %FIXME
			fprintf(fid,'source $ISSM_DIR/etc/environment.sh\n');
			fprintf(fid,'cd %s/%s/\n\n',cluster.executionpath,dirname);
			
			fprintf(fid,'which mpiexec\n\n');

			fprintf(fid,'mpiexec -np %i %s/%s %s %s/%s %s\n',cluster.nprocs(),cluster.codepath,executable,solution,cluster.executionpath,dirname,modelname);
			
			fprintf(fid,'export MPI_LAUNCH_TIMEOUT=520\n');
			fprintf(fid,'export MPI_GROUP_MAX=64\n\n');

			if ~io_gather %concatenate the output files:
				fprintf(fid,'cat %s.outbin.* > %s.outbin',modelname,modelname);
			end
			fclose(fid);

			%in interactive mode, create a run file, and errlog and outlog file
			if cluster.interactive
				fid=fopen([filename '.run'],'w');
				if cluster.interactive==10
						fprintf(fid,'module unload mpi-mvapich2/1.4.1/gcc\n');
						fprintf(fid,'mpiexec -np %i %s/%s %s %s %s\n',cluster.nprocs(),cluster.codepath,executable,solution,[pwd() '/run'],modelname);
				else
					if ~isvalgrind
						fprintf(fid,'mpiexec -np %i %s/%s %s %s %s\n',cluster.nprocs(),cluster.codepath,executable,solution,[cluster.executionpath '/Interactive' num2str(cluster.interactive)],modelname);
					else
						fprintf(fid,'mpiexec -np %i valgrind --leak-check=full %s/%s %s %s %s\n',cluster.nprocs(),cluster.codepath,executable,solution,[cluster.executionpath '/Interactive' num2str(cluster.interactive)],modelname);
					end
				end
				if ~io_gather %concatenate the output files:
					fprintf(fid,'cat %s.outbin.* > %s.outbin',modelname,modelname);
				end
				fclose(fid);
				fid=fopen([modelname '.errlog'],'w'); fclose(fid);
				fid=fopen([modelname '.outlog'],'w'); fclose(fid);
			end
		end %}}}

		function UploadQueueJob(cluster,modelname,dirname,filelist) % {{{

			%compress the files into one zip.
			%filelist contains full paths; tar with -C so only basenames are stored in the archive
			root=[issmdir() '/execution/' dirname];
			compressstring=['tar -C ' root ' -zcf ' dirname '.tar.gz'];
			for i=1:numel(filelist)
				if ~exist(filelist{i},'file')
					error(['File ' filelist{i} ' not found']);
				end
				[~,fname,fext]=fileparts(filelist{i});
				compressstring=[compressstring ' ' fname fext];
			end
			system(compressstring);

			disp('uploading input file and queueing script');
			if cluster.interactive
				directory=[cluster.executionpath '/Interactive' num2str(cluster.interactive)];
			else 
				directory=cluster.executionpath;
			end

			% if cluster.bbftp
			% 	issmbbftpout(cluster.name,directory,cluster.login,cluster.port,cluster.numstreams,{[dirname '.tar.gz']});
			% else
			% 	issmscpout(cluster.name,directory,cluster.login,cluster.port,{[dirname '.tar.gz']});
			% end

		end
		%}}}
		function LaunchQueueJob(cluster,modelname,dirname,filelist,restart,batch) % {{{

			%launch command, to be executed via ssh
			if cluster.interactive
				if ~isempty(restart)
					launchcommand=['cd ' cluster.executionpath '/Interactive' num2str(cluster.interactive)];
				else
					if cluster.interactive==10
						launchcommand=['cd ' pwd() '/run && tar -zxf ' dirname '.tar.gz'];
					else
						launchcommand=['cd ' cluster.executionpath '/Interactive' num2str(cluster.interactive) ' && tar -zxf ' dirname '.tar.gz'];
					end
				end
				issmssh(cluster.name,cluster.login,cluster.port,launchcommand);

			else
				cluster_defaults.LaunchQueueJobSbatch(cluster,modelname,dirname,filelist,restart,batch, 3);
			end

		end
		%}}}
		function Download(cluster,dirname,filelist) % {{{

			%copy files from cluster to current directory
			if cluster.interactive==10
				directory=[pwd() '/run/'];
			elseif ~cluster.interactive
				directory=[cluster.executionpath '/' dirname '/'];
			else
				directory=[cluster.executionpath '/Interactive' num2str(cluster.interactive) '/'];
			end

			% if cluster.bbftp
			% 	issmbbftpin(cluster.name, cluster.login, cluster.port, cluster.numstreams, directory, filelist);
			% else
			% 	issmscpin(cluster.name,cluster.login,cluster.port,directory,filelist);
			% end

		end %}}}
	end
end
