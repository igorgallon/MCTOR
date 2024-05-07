function [aptidaoArea custoArea] = OtimAreaGA(limiteArea,applicTag,numeroTarefas)

dimManycore = reshape(limiteArea,[],2);
S = applicTag(1,:);
T = applicTag(2,:);
W = applicTag(3,:);
Dec=[];
Obj=[];
Con=[];
[Dec,Obj,Con] = platemo('problem',@ManyCoreGA1,'algorithm',@GA,'parameter',{numeroTarefas,dimManycore(1),dimManycore(2),S,T,W}, 1);
posicao = find(Obj == min(Obj),1);
aptidaoArea = Dec(posicao,:);
custoArea = Obj(posicao,:);
    
end