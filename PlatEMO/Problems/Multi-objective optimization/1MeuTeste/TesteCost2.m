function Costs = TesteCost2(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
crm2=[0 1 6 9 4 5 3 8 0 2 0 7 10 11 0 0]
         Line=4
         Column=4
 
        [LN,CL]=ind2sub([Line Column],1:Line*Column);
        Pos_Tab=[LN' CL'];

        % Create distance table
        Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');
    
        
        % Calc Cost (Fault Tolerance)


        
   Graph=zeros(Line,Column);
   Idle=[];
   CC=[];

   Graph(crm2>0)=1;
            Graph=Graph';
   Idle=find(~Graph);
   Dist_Tab2=Dist_Tab;
   Dist_Tab2=Dist_Tab2-1;
   Dist_Tab2(Dist_Tab2<=0)=0;
   
   CC(:,:)=Dist_Tab2(:,[Idle]);
   [minValues, minIndices] = min(CC,[],2);

   Costs=sum(minValues);
end

