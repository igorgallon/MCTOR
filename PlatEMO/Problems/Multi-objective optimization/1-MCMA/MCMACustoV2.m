function CostResult = MCMACustoV2(Pop, S, T, P, nR, nC, objectivesList)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
    [L, R] = size(Pop);
    
    NumCore = nR*nC;
    
    % Calculate the Communication (energy) cost
    if ismember(utils.OBJ_ENERGY, objectivesList)
        % Gera os indices
        [LN, CL] = ind2sub([nR nC], 1:NumCore);
        Pos_Tab = [LN' CL'];
        % Cria uma tabela de distancias
        Dist_Tab = pdist2(Pos_Tab,Pos_Tab,'cityblock');
        
        sProc = Pop(:,S);
        tProc = Pop(:,T);
        Dist = zeros(L,length(S));
        cost = zeros(L,length(S));
        for s=1:L
            for x=1:length(S)
                Dist(s,x) = Dist_Tab(sProc(s,x), tProc(s,x));
            end
            cost(s,:) = Dist(s,:) .* P;
        end
        costCommunication = sum(cost, 2);

        % Concatenate the results
        CostResult = [costCommunication];
    end

    % Calculate the Load Balance cost
    if ismember(utils.OBJ_LOADBALANCE, objectivesList)
        Hist_Core = zeros(L,NumCore);
        for i=1:NumCore
            Hist_Core(:,i) = sum(Pop==i, 2);
        end
        costLoadBalance = abs(1-std(Hist_Core, 0, 2));
        
        % Concatenate the results
        CostResult = [CostResult, costLoadBalance];
    end
    
    % Calculate the Fault Tolerance cost
    if ismember(utils.OBJ_FAULTTOLERANCE, objectivesList)
        costFaultTolerance = zeros(L,1);
        for i=1:L
            ft = FaultToleranceCost(Pop(i,:), nR, nC);
            try
                costFaultTolerance(i,:) = ft;
            catch Exception
                disp(ft);
                throw(Exception);
            end
            % disp(ft);
        end
        
        % Concatenate the results
        CostResult = [CostResult, costFaultTolerance];
    end
end