function idle_cost=MCMA_idle_dist(ft_crm,nR,nC) 
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
%function idle_cost=idle_dist(crm2,Line,Column) 
%idle_cost: return the idle cost...
%ft_crm: chromosome...
%nR: Lines...
%nC: Columns...

% Create position table

% crm2=[2 3 0 0 4 5 0 0 0 0 0 0 0 0 0 0];
% Line=4;
% Column=4;

[LN,CL]=ind2sub([nR nC],1:nR*nC);
Pos_Tab=[LN' CL'];

% Create distance table
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');


% Calc Cost (Fault Tolerance)
Graph=zeros(nR,nC);
Idle=[];
CC=[];

Graph(ft_crm>0)=1;
Graph=Graph';
Idle=find(~Graph);
Dist_Tab(Dist_Tab<=0)=0;

CC(:,:)=Dist_Tab(:,[Idle]);
[minValues, ~] = min(CC,[],2);

idle_cost=sum(minValues);

TF = isempty(idle_cost);

if TF == 1
            idle_cost=50;
end