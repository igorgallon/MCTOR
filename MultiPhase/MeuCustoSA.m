function [resultCost] = MeuCustoSA(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

result = [];
numApp = numel(varargin);

for i = 1:numApp
    if i == numApp
        auxResult = varargin{i};
    else if i == numApp - 1
            auxiliarDim = varargin{i};
        else
            areasAtuais{i} = varargin{i};
        end
    end
end

auxiliarCore = zeros(auxiliarDim);

controleCusto = ((numel(auxResult)-1)/2)+1;
controleResult = auxResult(1:controleCusto);
for j=1:controleCusto

    if j == 1
        result = [auxResult(j)];
    else
        result = [result auxResult(j+controleCusto-1) auxResult(j)];
    end
end

if numel(controleResult) > numel(unique(controleResult)) || ~isempty(find(result < 1,1))
    auxiliarCusto = auxiliarDim(1) * auxiliarDim(2) * 100;
else
    [auxiliarCore,auxiliarCusto] = ColocaArea(areasAtuais, auxiliarDim, result);
end

resultCost = auxiliarCusto;
% load 'cellCost_Salva.mat' cellCost;
% bestresult = cell2mat(cellCost{1}(2));
% if bestresult == 0
%     bestresult = auxiliarDim(1) * auxiliarDim(2) * 100;
% end
% 
% if resultCost <= bestresult
%     cellCost{1} = {result auxiliarCusto auxiliarCore};
%     save('cellCost_Salva.mat', 'cellCost');
% end
end

