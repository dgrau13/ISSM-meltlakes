%SGLStats class definition
%
%   Usage:
%      sglstats=sglstats();

classdef sglstats
	properties (SetAccess=public) 
		hurst = NaN;
        sigma = NaN;
        runoff = NaN;
        meanwl = NaN;
        meanF = NaN;
	end
	methods
		function self = sglstats(varargin) % {{{
			switch nargin
				case 0
					self=setdefaultparameters(self);
				otherwise
					error('constructor not supported');
			end
		end % }}}
		function self = extrude(self,md) % {{{
            
		end % }}}
		function self = setdefaultparameters(self) % {{{
			
		  self.hurst = 0.4;
		  self.sigma   = 10;
          self.runoff = 0;
          self.meanwl = 0;
          self.meanF = 0;
		end % }}}
		function md = checkconsistency(self,md,solution,analyses) % {{{
			%Early return
			if (~strcmp(solution,'TransientSolution') | md.transient.ismovingfront==0), return; end

			md = checkfield(md,'fieldname','sglstats.hurst','>=',0,'<=',1,'size',[md.mesh.numberofvertices 1]);
            md = checkfield(md,'fieldname','sglstats.sigma','>',0,'<=',1,'size',[md.mesh.numberofvertices 1]);
			md = checkfield(md,'fieldname','sglstats.runoff','>=',0,'size',[md.mesh.numberofvertices 1]);
            md = checkfield(md,'fieldname','sglstats.meanwl', '>=',0,'size',[md.mesh.numberofvertices 1]);
            md = checkfield(md,'fieldname','sglstats.meanF', '>=',0,'<=',1,'size',[md.mesh.numberofvertices 1]);
		end % }}}
		function disp(self) % {{{
			disp(sprintf('   supraglacial melt lake predictor parameters:'));

			disp(sprintf('\n   surface roughness and sgl parameters:'));
			fielddisplay(self,'Hurst','is the quantification of the self-affinity of the glacial surface (default H = 0.4, mean Hurst of glaciers');
			fielddisplay(self,'sigma','is the roughness amplitude of the glacial surface or standard deviation of the mean elevation of the surface [m]');
            fielddisplay(self,'runoff','available melt water supply to the glacial surface [m]');
			fielddisplay(self,'meanwl','is the calculated mean lake depth [m] (default is 0)');
			fielddisplay(self,'meanF',' is the calculated mean area fraction of SGLs on the glacial surface (default is 0)');

		end % }}}
		function marshall(self,prefix,md,fid) % {{{
			yts=md.constants.yts;
			WriteData(fid,prefix,'object',self,'fieldname','hurst','format','DoubleMat','mattype',1);
            WriteData(fid,prefix,'object',self,'fieldname','sigma','format','DoubleMat','mattype',1);
			WriteData(fid,prefix,'object',self,'fieldname','runoff','format','DoubleMat','mattype',1);
            WriteData(fid,prefix,'object',self,'fieldname','meanwl','format','DoubleMat','mattype',1);
            WriteData(fid,prefix,'object',self,'fieldname','meanF','format','DoubleMat','mattype',1);
		end % }}}
	end
end
