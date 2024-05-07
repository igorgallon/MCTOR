function costResult = MCMACustoV2(Pop, S, T, P, nR, nC, objectivesList)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023 and Igor Gallon
% to optimize Many-Core
% costResult = [communicationResults, {loadBalance | faultTolerance | (loadBalance , faultTolerance)}]
%--------------------------------------------------------------------------
    [L, R] = size(Pop);
    
    nCores = nR * nC;

    % Calculate the Communication (energy) cost
    if ismember(utils.OBJ_ENERGY, objectivesList)
        % Gera os indices
        [LN, CL] = ind2sub([nR nC], 1:nCores);
        Pos_Tab = [LN' CL'];
        % Cria uma tabela de distancias
        Dist_Tab = pdist2(Pos_Tab,Pos_Tab,'cityblock');
        
        sProc = Pop(:,S);
        tProc = Pop(:,T);
        Dist = zeros(L,length(S));
        cost = zeros(L,length(S));
        for s = 1:L
            for x = 1:length(S)
                try
                    Dist(s,x) = Dist_Tab(sProc(s,x), tProc(s,x));
                catch
                    disp('err');
                end
            end
            cost(s,:) = Dist(s,:) .* P;
        end
        costCommunication = sum(cost, 2) + 1;

        % Concatenate the results
        costResult = [costCommunication];
    end

    % Calculate the Load Balance cost
    if ismember(utils.OBJ_LOADBALANCE, objectivesList)
        Hist_Core = zeros(L,nCores);
        for i = 1:nCores
            Hist_Core(:,i) = sum(Pop==i, 2);
        end
        costLoadBalance = abs(1-std(Hist_Core, 0, 2));
        
        % Concatenate the results
        costResult = [costResult, costLoadBalance];
    end
    
    % Calculate the Fault Tolerance cost
    if ismember(utils.OBJ_FAULTTOLERANCE, objectivesList)
        costFaultTolerance = zeros(L,1);
        for i = 1:L
            ft = FaultToleranceCost(Pop(i,:), nR, nC);
            if isnan(ft)
                disp('ERROR');
            end
            try
                costFaultTolerance(i,:) = ft;
            catch Exception
                disp(ft);
                throw(Exception);
            end
        end
        
        % Concatenate the results
        costResult = [costResult, costFaultTolerance];
    end
end