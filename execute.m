
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
addpath(genpath([pwd,'\PlatEMO_v4_1']))

nTask = 5;
nRow = 4;
nCol = 4;

% Tasks graph definition
S = [1 1 2 3 3 4];          % Source Node ID
T = [2 3 4 4 5 5];          % Target Node ID
W = [10 20 30 40 50 60];    % Vertex weights
Enc = 6;
params = {nTask,nRow,nCol,S,T,W,Enc};

%[Dec, Obj, Con] = platemo('problem',@ManyCoreV1,'algorithm',@NSGAII,'parameter',params,'save', 1);
%[Dec, Obj, Con] = platemo('problem',@MCTOF,'algorithm',@NSGAII,'parameter',params,'save', 1);
%drawSolution(nRow, nCol, [0  1  2  0  5  3  4  0  0  0  0  0  0  0  0  0]);

%parseTGFF('D:\Projects\tgff_v3_1\examples\simple.vcg');