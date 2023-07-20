% nTask = 7;	% Number of Tasks
% Line = 2;   %Number of Image
% Column = 2; %Number of Image
% S = [1 1 1 2 3 4 4 5 6]; % Grafo
% T = [2 4 3 4 4 5 6 7 7]; % Grafo
% P = [10 20 30 45 55 40 50 60 70];

nTask = 26;	% Number of Tasks
Line = 4;   %Number of Image
Column = 4; %Number of Image
S = [1 1 2 3 3 4 2 5 5 7 4 6 1 1 2 3 4 3 5 5 6 2 6 7 4 7 9 10 9 11 10 12 12 14 11 8 13 13 8 14 16 17 16 18 15 19 19 17 15 20 23 22 22];
T = [2 3 4 4 5 5 5 6 7 8 8 8 2 3 4 4 5 6 6 7 7 8 8 8 9 9 10 11 11 12 12 13 14 15 16 16 16 17 17 17 18 18 19 19 20 21 22 22 23 23 24 25 26];
P = [43 26 45 25 2 14 12 23 39 9 14 33 20 8 11 33 39 41 2 32 12 39 35 9 35 18 12 40 23 17 24 41 21 45 18 41 0 40 31 10 37 19 34 23 12 38 43 11 7 39 47 18 46];

Nop=MCMAPop(5, nTask, Line*Column);
[LN,CL]=ind2sub([Line Column],1:Line*Column);
Pos_Tab=[LN' CL'];
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');
custo = MCMACustoV2(Nop, Dist_Tab, 4, S, T, P, 2, 2);
