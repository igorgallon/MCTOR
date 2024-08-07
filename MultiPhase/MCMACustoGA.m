function [CostResultA CostResultB] = MCMACustoGA(Pop, Dist_Tab, NumCore, S, T, P, nR, nC)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
[L, R] = size(Pop);
MeuCustoEsult = zeros(1,L);
Num_Core = nR * nC;
%Calculo custo de comunicação
sProc = Pop(:,S);
tProc = Pop(:,T);
for s = 1:L
    for x = 1:length(S)
        try
            Dist(s,x) = Dist_Tab(sProc(s,x), tProc(s,x));
        catch
            disp('Error Dist');
        end
    end    
    cost(s,:)  = Dist(s,:) .* P;
end

%Calculo de Load Balance
for i=1:Num_Core
    Hist_Core(:,i) = sum(Pop==i, 2);
end

%cost2=MCMA_idle_dist(A,nR,nC);
%cost2 = abs(1-MCMA_Load_balance(A, nR, nC));
cost2 = abs(1-std(Hist_Core,0,2));
cost1 = sum(cost,2);
%CostResultA = [sum(cost, 2)];
CostResultA = [max(cost,[], 2)]; %Alterado para usar a Latência de cada solução
CostResultB = sum(cost);

end