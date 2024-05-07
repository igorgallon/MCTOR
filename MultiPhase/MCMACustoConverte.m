function [CostResultA, CostResultB] = MCMACustoConverte(Pop, Dist_Tab, NumCore, S, T, P, nR, nC)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 10/04/2024
% to optimize Many-Core
%--------------------------------------------------------------------------

numeroApp = 4; %entrar com a quantidade de aplicações

%Começa o calculo

[L, R] = size(Pop);
MeuCustoEsult=zeros(1,L);
Num_Core = nR * nC;

%Calculo custo de comunicação
sProc = Pop(:,S);
tProc = Pop(:,T);
for s=1:L
    for x=1:length(S)
        if sProc(s,x) == 0 || tProc(s,x) == 0
            Dist(s,x) = 0;
        else
            Dist(s,x) = Dist_Tab(sProc(s,x), tProc(s,x));
        %Dist = diag(Dist);
        %Dist = Dist';
        end
    end
cost(s,:)  = Dist(s,:) .* P;
cost_Fault(s,:) = CalcCustoFT(Pop(s,:), nR, nC);
end

%Calculo de Load Balance
for i=1:Num_Core
    Hist_Core(:,i) = sum(Pop==i, 2);
end

costLoadBal = zeros(L,1);
posNoC = zeros(nR, nC);

for y = 1 : L
    posNoC = reshape(Hist_Core(y,:), [nR, nC]);
    for z = 1 : nR
        for w = 1 : nC
            if posNoC(z, w)
                if z == 1 && w == 1
                    costLoadBal(y) = costLoadBal(y) + posNoC(z+1, w) + posNoC(z, w+1);
                elseif z == nR && w == 1
                    costLoadBal(y) = costLoadBal(y) + posNoC(z-1, w) + posNoC(z, w+1);
                elseif z == 1 && w == nC
                    costLoadBal(y) = costLoadBal(y) + posNoC(z+1, w) + posNoC(z, w-1);
                elseif z == nR && w == nC
                    costLoadBal(y) = costLoadBal(y) + posNoC(z-1, w) + posNoC(z, w-1);
                elseif z == 1
                    costLoadBal(y) = costLoadBal(y) + posNoC(z+1, w) + posNoC(z, w+1) + posNoC(z, w-1);
                elseif z == nR
                    costLoadBal(y) = costLoadBal(y) + posNoC(z-1, w) + posNoC(z, w+1) + posNoC(z, w-1);
                elseif w == 1
                    costLoadBal(y) = costLoadBal(y) + posNoC(z+1, w) + posNoC(z-1, w) + posNoC(z, w+1);
                elseif w == nC
                    costLoadBal(y) = costLoadBal(y) + posNoC(z+1, w) + posNoC(z-1, w) + posNoC(z, w-1);
                else
                    costLoadBal(y) = costLoadBal(y) + posNoC(z+1, w) + posNoC(z-1, w) + posNoC(z, w+1) + posNoC(z, w-1);
                end
            end
        end
    end
    
end


%cost2=MCMA_idle_dist(A,nR,nC);
%cost2 = abs(1-MCMA_Load_balance(A, nR, nC));
cost21 = abs(1-std(Hist_Core,0,2));
cost1 = sum(cost,2)./50;
latencia = max(cost,[],2);
%cost1 = (cost11)/(max(cost11));
%cost2 = (cost21)/(max(cost21));
%cost2 = costLoadBal ./ (((nR - 2) * (nC - 2) * 4) + (((nR - 2) + (nC - 2)) * 6) + 8);
cost2 = costLoadBal;

%CostResultA = [sum(cost, 2) cost2];
%CostResultA = [cost1 cost2];
%CostResultA = [cost1 cost_Fault];
%CostResultA = [latencia cost2];
CostResultA = [latencia cost_Fault];
CostResultB = sum(cost);

end

%end


