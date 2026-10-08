%Test Name: SquareShelfConstrainedStressSSA2d
md=triangle(model(),'../Exp/Square.exp',50000.);
md=setmask(md,'all','');
md=parameterize(md,'../Par/SquareShelfConstrained.par');
md=setflowequation(md,'SSA','all');
md.cluster=generic('name',oshostname(),'np',2);

if true
    cluster=ccr;
    cluster.login = 'dgrau';
    cluster.numnodes =1;
    cluster.ntasks = 2;
    cluster.cpuspertask =2;
    cluster.time =1/30;
    cluster.partition = 'general-compute';
    cluster.qos = 'general-compute';
    cluster.account = 'ghub';
    cluster.mem = 2;
    cluster.jobname = 'Test101';
    cluster.interactive=0; 
    cluster.port=0;
    cluster.srcpath = '/user/dgrau/ISSM-meltlakes';
    cluster.codepath = '/user/dgrau/ISSM-meltlakes/bin';
    cluster.executionpath = '/user/dgrau/ISSM-meltlakes/execution';
    md.cluster=cluster;
end

md.stressbalance.requested_outputs={'default','DeviatoricStressxx','DeviatoricStressyy','DeviatoricStressxy','MassFlux1','MassFlux2','MassFlux3','MassFlux4','MassFlux5','MassFlux6'};
md.outputdefinition.definitions={...
    massfluxatgate('name','MassFlux1','profilename',['../Exp/MassFlux1.exp'],'definitionstring','Outputdefinition1'),...
    massfluxatgate('name','MassFlux2','profilename',['../Exp/MassFlux2.exp'],'definitionstring','Outputdefinition2'),...
    massfluxatgate('name','MassFlux3','profilename',['../Exp/MassFlux3.exp'],'definitionstring','Outputdefinition3'),...
    massfluxatgate('name','MassFlux4','profilename',['../Exp/MassFlux4.exp'],'definitionstring','Outputdefinition4'),...
    massfluxatgate('name','MassFlux5','profilename',['../Exp/MassFlux5.exp'],'definitionstring','Outputdefinition5'),...
    massfluxatgate('name','MassFlux6','profilename',['../Exp/MassFlux6.exp'],'definitionstring','Outputdefinition6')...
    };

md = solve(md,'Stressbalance');





