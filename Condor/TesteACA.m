% S = [1  2   3   4   4   5   6   7   8   8   9   10  11  12  12  12  13  14  15  15  16];
% T = [2  3   4   5   16  6   7   8   9   10  10  9   12  9   6   13  14  15  11  13  5];
% W = [70 362 362 362 49  357 353 300 313 500 313 94  16  16  16  16  157 16  16  16  27];
%VOPD
S = [1    2   3   4  4   5   6   7   8   8   9 10 11 12 12 12  13 14 15 15 16];
T = [2    3   4   5 16   6   7   8   9  10  10  9 12  6  9 13  14 15 11 13  5];
W = [70 362 362 362 49 357 353 300 313 500 313 94 16 16 16 16 157 16 16 16 27];

NocX = 5;
NocY = 5;
DP = 0.5;   % pct da pop que vai sofrer mutação
PC = 0.05;  % quanto incrementa/decrementa DP ao longo das gen
N = 100;    % tamanho pop
inferiorDP = 0.1;
superiorDP = 0.9;   
parada = 100;   % maxFE
repete = 100;   
% Pop = PopACA(N, NocX, NocY, S, T, W);
% Custo = CustoACA(Pop,NocX, NocY, S, T, W);
% [~, indicesOrdenados] = sort(Custo);
% Pop = Pop(indicesOrdenados,:);
tic;

%result4x4 = cell(repete, 2);
for i=1 : repete
    disp(i)
    [resPop resCusto] = algoACA(N, parada, inferiorDP, superiorDP, DP, PC, NocX, NocY, S, T, W);
    result5x5{i,1} = resPop; % melhor pop ao final das geracoes
    result5x5{i,2} = resCusto;  % custo da pop
end
toc;
disp(['Tempo= ', num2str(toc)]);
save result5x5.mat;


% % Menor possivel
% for j = 1: max(S)
%     indices = [find(S == j) find(T == j)];
%     clusters(j) = sum(W(indices));
% end
%     menorCusto = sum(clusters);
% 
% custoMedio = mean(Custo);
% 
% for i = 1 : 200
%     newN = floor(N * DP);
%     % Tratamento de erro newN = 0
%     if newN == 0
%         newN = 1;
%     end
%     newPop = PopACA(newN, NocX, NocY, S, T, W);
%     newCusto = CustoACA(newPop, NocX, NocY, S, T, W);
%     Pop(N - newN + 1:end,:) = newPop;
%     Custo(numel(Custo) - numel(newCusto) + 1:end) = newCusto;
%     
%     [~, indicesOrdenados] = sort(Custo);
%     Pop = Pop(indicesOrdenados, :);
%     Custo = sort(Custo);
%     
%     newcustoMedio = mean(Custo);
%     
%     if newcustoMedio > custoMedio
%         DP = DP + PC;
%         if DP >= 0.8
%             DP = 0.8;
%         end
%     else
%         DP = DP - PC;
%         if DP <= 0.1
%             DP = 0.1;
%         end
%     end
%     custoMedio = newcustoMedio;
%     disp(['Exec= ', num2str(i), ' : Média= ', num2str(custoMedio), ' : Menor= ', num2str(Custo(1)), ' : DP= ', num2str(DP), ' : Alvo= ', num2str(menorCusto)]);
% end