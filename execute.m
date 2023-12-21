
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
addpath(genpath([pwd,'\PlatEMO']))
addpath(genpath([pwd,'\thirdparty']))

% clear all;
% load('popinit.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('matlab.mat');

utils.drawSolution([], nR, nC, 24, p, 1, true);

ft = FaultToleranceCost(p, nR, nC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Diagonal raster I
% r = 1;
% s = 1;
% while s <= nColumns
%     i = r;
%     j = s;
%     while i > 0 && j <= nColumns
%         out(k) = m(i,j);
%         i = i-1;
%         j = j+1;
%         k = k+1;
%     end
%     if r < nRows
%         r = r+1;
%     else
%         s = s+1;
%     end
% end

% Diagonal raster II
% r = 1;
% s = 1;
% while r <= nRows
%     i = r;
%     j = s;
%     while i <= nRows && j > 0
%         out(k) = m(i,j);
%         i = i+1;
%         j = j-1;
%         k = k+1;
%     end
%     if s < nColumns
%         s = s+1;
%     else
%         r = r+1;
%     end
% end
