
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------


S1 = [1 2 1 3 4 4 2];
T1 = [2 3 4 5 6 7 8];
W1 = [21 42 31 45 49 45 4];
params1 = {8, 4, 4, S1, T1, W1, 7};

S2 = [1 1 2 3 3 4 2 5 5 7 4 6 1 1 2 3 4 3 5 5 6 2 6 7 4 7 9 10 9 11 10 12 12 14 11 8 13 13 8 14 16 17 16 18 15 19 19 17 15 20 23 22 22];
T2 = [2 3 4 4 5 5 5 6 7 8 8 8 2 3 4 4 5 6 6 7 7 8 8 8 9 9 10 11 11 12 12 13 14 15 16 16 16 17 17 17 18 18 19 19 20 21 22 22 23 23 24 25 26];
W2 = [43 26 45 25 2 14 12 23 39 9 14 33 20 8 11 33 39 41 2 32 12 39 35 9 35 18 12 40 23 17 24 41 21 45 18 41 0 40 31 10 37 19 34 23 12 38 43 11 7 39 47 18 46];
params2 = {26, 4, 4, S2, T2, W2, 7};
%params2 = {26, 4, 4, S, T, W, 7};

S = cat(2, S2, (S1 + 26));
T = cat(2, T2, (T1 + 26));
W = cat(2, W2, W1);
params = {26+8, 4, 4, S, T, W, 7};
[params, LenghtGrafos] = UniGrafo({params1, params2});

%[Dec,Obj,Con] = platemo('problem',@ManyCoreMAV1,'algorithm',@NSGAII,'parameter',{nTask,Line,Column,S,T,P},'save', 1);
[Dec,Obj,Con] = platemo('N',100,'problem',@ManyCoreMAV1,'algorithm',@NSGAII,'parameter',params,'save', 1);
plot(Obj(:,1), Obj(:,2),'bo')