function [resultCost] = MCCustoSA(varargin)

    resultCost = [];
    numApp = numel(varargin);
    
    for i = 1:numApp
        switch i
            case 1
                auxNumNoC = varargin{i};
            case 2
                auxS = varargin{i};
            case 3
                auxT = varargin{i};
            case 4
                auxW = varargin{i};
            case 5
                auxTask = varargin(i);
            otherwise
                auxData = varargin{i};
        end
    end
    
    Dist = ones(1,length(auxS))* auxTask{1};
    
    [LN,CL]=ind2sub(auxNumNoC,1:auxNumNoC(1)*auxNumNoC(2));
    Pos_Tab=[LN' CL'];
    % Cria uma tabela de distancias
    Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');
    
    sProc = auxData(:,auxS);
    tProc = auxData(:,auxT);
    s = 1;
    
    
    if numel(unique(auxData)) == auxTask{1} && isempty(find(auxData < 1,1))
        for x=1:length(auxS)
            Dist(s,x) = Dist_Tab(sProc(s,x), tProc(s,x));
        end
        resultCost(s,:)  = max(Dist(s,:) .* auxW);
    else
        resultCost(s,:)  = max(Dist(s,:) .* auxW) * 100;
    end

end


