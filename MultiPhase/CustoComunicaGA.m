function [CostResultA, CostResultB, CostFTIndiv] = CustoComunicaGA(Pop, Dist_Tab, NumCore, Scost, Tcost, Pcost, nR, nC)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
[L, R] = size(Pop);
MeuCustoEsult=zeros(1,L);
Num_Core = nR * nC;
        if ~isempty (find(Pop > (nC*nR)))
            find(Pop > (nC*nR))
        end

%Calculo custo de comunicação
sProc = Pop(:,Scost);
tProc = Pop(:,Tcost);
for s=1:L
    for x=1:length(Scost)
        Dist(s,x) = Dist_Tab(sProc(s,x), tProc(s,x));
        %Dist = diag(Dist);
        %Dist = Dist';
    end
cost(s,:)  = Dist(s,:) .* Pcost;
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

costFaultTol = zeros(nR, nC);
posNoC = zeros(nR, nC);

for y = 1 : L
    posNoC = reshape(Hist_Core(y,:), [nR, nC]);
    for z = 1 : nR
        for w = 1 : nC
            if posNoC(z, w)
                if z == 1 && w == 1
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z+1, w) + ~posNoC(z, w+1);
                elseif z == nR && w == 1
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z-1, w) + ~posNoC(z, w+1);
                elseif z == 1 && w == nC
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z+1, w) + ~posNoC(z, w-1);
                elseif z == nR && w == nC
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z-1, w) + ~posNoC(z, w-1);
                elseif z == 1
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z+1, w) + ~posNoC(z, w+1) + ~posNoC(z, w-1);
                elseif z == nR
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z-1, w) + ~posNoC(z, w+1) + ~posNoC(z, w-1);
                elseif w == 1
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z+1, w) + ~posNoC(z-1, w) + ~posNoC(z, w+1);
                elseif w == nC
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z+1, w) + ~posNoC(z-1, w) + ~posNoC(z, w-1);
                else
                    costFaultTol(z, w) = costFaultTol(z, w) + ~posNoC(z+1, w) + ~posNoC(z-1, w) + ~posNoC(z, w+1) + ~posNoC(z, w-1);
                end
            end
        end
    end
end
auxFT = reshape(costFaultTol',1,[]);
    %CostIndiv(f) = sum(cost(compApp(1,f):compApp(2,f)));
    CostFTIndiv = sum(auxFT);

%cost2=MCMA_idle_dist(A,nR,nC);
%cost2 = abs(1-MCMA_Load_balance(A, nR, nC));
cost21 = abs(1-std(Hist_Core,0,2));
cost1 = sum(cost,2);
%cost1 = (cost11)/(max(cost11));
%cost2 = (cost21)/(max(cost21));
cost2 = costLoadBal ./ (((nR - 2) * (nC - 2) * 4) + (((nR - 2) + (nC - 2)) * 6) + 8);

%CostResultA = [sum(cost, 2) cost2];
CostResultA = cost2;
CostResultB = sum(cost);

end

%end


