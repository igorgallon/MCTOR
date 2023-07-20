function [CostResultA, CostResultB] = MCMACusto(Pop, Dist_Tab, NumCore, S, T, P, nR, nC)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
[L, R] = size(Pop);
MeuCustoEsult=zeros(1,L);

% Inicializa os vetores de processadores
sProc=zeros(1,length(S));
tProc=zeros(1,length(T));
%Calculo por individuo
for m=1:L
    A=Pop(m, :);
    %Procura os indices e converte
    for i=1:length(S)
        %sProc(i)= find(S==A(i));
        sProc(i)= A(S(i));
        tProc(i)= A(T(i));
    end

    %Inicializa os custos
    cost=zeros(1,length(S));
    %Calcula os custos sem peso
    for i=1:length(S)
        cost(i)=Dist_Tab(sProc(i),tProc(i));    
    end
    %Calcula os custos com peso (P)
    costcompeso=zeros(1,length(S));
    for i=1:length(S)
        costcompeso(i)=Dist_Tab(sProc(i),tProc(i))*P(i); 
    end
%cost2=MCMA_idle_dist(A,nR,nC);
cost2 = abs(1-MCMA_Load_balance(A, nR, nC));
cost2 = abs(1-std(A,1));
CostResultA(m,:) = [sum(costcompeso) cost2];
CostResultB(m) = sum(cost);

end

end



