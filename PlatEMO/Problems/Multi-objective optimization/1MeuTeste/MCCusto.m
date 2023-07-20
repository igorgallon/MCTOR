function [CostResultA, CostResultB] = MeuCustoF(Pop, Dist_Tab, Tarefas, S, T, P, nR, nC)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
[L, R] = size(Pop);
MeuCustoEsult=zeros(1,L);

%Calculo por individuo
for m=1:L
    A=Pop(m, :);
    %Procura os indices e converte
%     for i=1:length(S)
%         sProc(i)= find(A==S(i));
%         tProc(i)= find(A==T(i));
%     end
% Inicializa os vetores de processadores
sProc=zeros(1,length(S));
tProc=zeros(1,length(T));

%Procura os indices e converte
for i=1:length(S)
    sProc(i)= find(A==S(i));
    tProc(i)= find(A==T(i));
end
    %Inicializa os custos
    cost=zeros(1,Tarefas);
    %Calcula os custos sem peso
    for i=1:Tarefas
        cost(i)=Dist_Tab(sProc(i),tProc(i));    
    end
    %Calcula os custos com peso (P)
    costcompeso=zeros(1,Tarefas);
    for i=1:Tarefas
        costcompeso(i)=Dist_Tab(sProc(i),tProc(i))*P(i); 
    end
cost2=idle_dist(A,nR,nC);
CostResultA(m,:) = [sum(costcompeso) cost2];
CostResultB(m) = sum(cost);

end

end



