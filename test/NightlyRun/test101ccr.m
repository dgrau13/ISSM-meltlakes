%Steps & Load Only: 0 - Run Simulation, 1 - Compile Model Output 
step = 1;loadonly=0;
%Test Name: SquareShelfConstrainedStressSSA2d

issm_dir = '/user/dgrau/ISSM-meltlakes';
codepath = [issm_dir '/bin'];
execpath = [issm_dir '/execution'];
org = organizer('repository','','prefix','test101ccr','steps',step);

mycluster = ccr('login','dgrau','numnodes',1,'ntasks',2,'cpuspertask',2,'time',1/30,'account','ghub','mem',2,'srcpath',issm_dir,'codepath',codepath,'executionpath',execpath,'jobname','Test101');

if perform(org,'test101ccr')
md=triangle(model(),'../Exp/Square.exp',50000.);
md=setmask(md,'all','');
md=parameterize(md,'../Par/SquareShelfConstrained.par');
md=setflowequation(md,'SSA','all');
md.cluster=mycluster;

md.stressbalance.requested_outputs={'default','DeviatoricStressxx','DeviatoricStressyy','DeviatoricStressxy','MassFlux1','MassFlux2','MassFlux3','MassFlux4','MassFlux5','MassFlux6'};
md.outputdefinition.definitions={...
    massfluxatgate('name','MassFlux1','profilename',['../Exp/MassFlux1.exp'],'definitionstring','Outputdefinition1'),...
    massfluxatgate('name','MassFlux2','profilename',['../Exp/MassFlux2.exp'],'definitionstring','Outputdefinition2'),...
    massfluxatgate('name','MassFlux3','profilename',['../Exp/MassFlux3.exp'],'definitionstring','Outputdefinition3'),...
    massfluxatgate('name','MassFlux4','profilename',['../Exp/MassFlux4.exp'],'definitionstring','Outputdefinition4'),...
    massfluxatgate('name','MassFlux5','profilename',['../Exp/MassFlux5.exp'],'definitionstring','Outputdefinition5'),...
    massfluxatgate('name','MassFlux6','profilename',['../Exp/MassFlux6.exp'],'definitionstring','Outputdefinition6')...
    };

md = solve(md,'Stressbalance','runtimename', false,'loadonly',loadonly);
if loadonly
    md=loadresultsfromcluster(md);
    savemodel(org,md);
end
end







