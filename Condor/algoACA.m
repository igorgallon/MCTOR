function [resPop resCusto] = algoACA(N, parada, inferiorDP, superiorDP, DP, PC, NocX, NocY, S, T, W)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Pop = PopACA(N, NocX, NocY, S, T, W);
Custo = CustoACA(Pop,NocX, NocY, S, T, W);
[~, indicesOrdenados] = sort(Custo);
Pop = Pop(indicesOrdenados,:);

% Menor possivel
for j = 1: max(S)
    indices = [find(S == j) find(T == j)];
    clusters(j) = sum(W(indices));
end
    menorCusto = sum(clusters);

custoMedio = mean(Custo);

for i = 1 : parada
    newN = floor(N * DP);
    % Tratamento de erro newN = 0
    if newN == 0
        newN = 1;
    end
    newPop = PopACA(newN, NocX, NocY, S, T, W);
    newCusto = CustoACA(newPop, NocX, NocY, S, T, W);
    Pop(N - newN + 1:end,:) = newPop;
    Custo(numel(Custo) - numel(newCusto) + 1:end) = newCusto;
    
    [~, indicesOrdenados] = sort(Custo);
    Pop = Pop(indicesOrdenados, :);
    Custo = sort(Custo);
    
    newcustoMedio = mean(Custo);
    
    if newcustoMedio > custoMedio
        DP = DP + PC;
        if DP >= superiorDP
            DP = superiorDP;
        end
    else
        DP = DP - PC;
        if DP <= inferiorDP
            DP = inferiorDP;
        end
    end
    custoMedio = newcustoMedio;
    disp([' : Média= ', num2str(custoMedio), ' : Menor= ', num2str(Custo(1)), ' : DP= ', num2str(DP), ' : Alvo= ', num2str(menorCusto)]);
end

resPop = Pop;
resCusto = Custo;
end

