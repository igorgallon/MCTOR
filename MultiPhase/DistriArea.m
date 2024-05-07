function [aptidaoAreaTotal custoAreaTotal squareAreaTotal] = DistriArea(varargin)
%UNTITLED

    numMatrizes = numel(varargin);

    
    for i = 1:numMatrizes

        matrizAtual = varargin{i};
        
        % Mostra Matriz
        %disp(['Matriz ' num2str(i) ' tem tamanho ' num2str(size(matrizAtual))]);
        matrizParcial = matrizAtual(1:2,:);
        numeroTarefas = max(matrizParcial(:));
        limiteDim = ceil(sqrt(numeroTarefas))+1;
        squareArea = fatoracaoEmDois(limiteDim, limiteDim,numeroTarefas);
        S = matrizAtual(1,:);
        T = matrizAtual(2,:);
        W = matrizAtual(3,:);
        aptidaoArea = zeros(length(squareArea),numeroTarefas);
        custoArea=[];
        
        for j = 1 : length(squareArea)
            [aptidaoArea(j,:) custoArea(j,:)]= OtimAreaGA(squareArea(:,j) ,matrizAtual, numeroTarefas);
        end
        
        squareAreaTotal{i} = squareArea;
        aptidaoAreaTotal{i}= aptidaoArea;
        custoAreaTotal{i} = custoArea;
    end
    
%     aptidaoArea = squareAreaTotal;
%     melhorCusto = custoAreaTotal;
end

function [squareArea] = fatoracaoEmDois(LimiteX, LimiteY, numeroTask)
    limiteX = 1:LimiteX;
    limiteY = 1:LimiteY;
    matrizCombinar = combvec(limiteX, limiteY);
    tamanhosTotai = prod(matrizCombinar,1);
    position = find(tamanhosTotai >= numeroTask);
    squareArea = matrizCombinar(:,position);
    return
end
