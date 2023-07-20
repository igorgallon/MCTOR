
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
S = [1 1 2 3 3 4]; % Grafo
T = [2 3 4 4 5 5]; % Grafo
P = [10 20 30 40 50 60]; % Pesos
[Dec,Obj,Con] = platemo('problem',@ManyCoreV1,'algorithm',@NSGAII,'parameter',{5,3,3,S,T,P},'save', 1);