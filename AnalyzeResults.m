clear;
close all;

% folder = 'batch\20240108_014756';
folder = 'batch\20240123_141481_firstgen';
% folder = 'batch\20240209_113072_lastgen';

load([folder '\results.mat']);

params = readtable([folder '\params.txt'], 'Delimiter', ',', ReadVariableNames=true);
[n, l] = size(params);

showStatistics('4x4 (pcb circle)', 1, 5, params, batch_results);
showStatistics('4x4 (pcb square)', 6, 10, params, batch_results);
showStatistics('4x4 (pcb track)', 11, 15, params, batch_results);
showStatistics('4x4 (satellite)', 16, 20, params, batch_results);

function [] = showStatistics(grid_name, init, finish, params, batch_results)
    
    len = finish-init;

    e = zeros(50, len);
    lb = zeros(50, len);
    label = cell(1, len);
    idx = 1;

    for i=init:finish
        input = params{i,1}{1};
        grid = params{i,2}{1};
        pop_size = params{i,3};
        mut_rate = params{i,4};
        algorithm = params{i,6}{1};

        e_nsga = batch_results{i,1}.best_objectives(:,1);
        lb_nsga = batch_results{i,1}.best_objectives(:,2);

        e(:,idx) = e_nsga;
        lb(:,idx) = lb_nsga;

        label{1,idx} = [algorithm '_' num2str(mut_rate)];
        idx = idx + 1;
    end

    figure;
    boxplot(e, 'Labels',label);
    title(['Energy - ' grid_name]);

    figure;
    boxplot(lb, 'Labels',label);
    title(['Load Balance - ' grid_name]);
    
    % j = init;
    % % grid = params{j,2}{1};
    % % mut_rate = params{j,4};
    % % algorithm = params{j,6}{1};
    % 
    % e0 = batch_results{j,1}.best_objectives(:,1);
    % lb0 = batch_results{j,1}.best_objectives(:,2);
    % 
    % for k=1:4
    %     idx = j+(3*k);
    %     disp([num2str(j) '  ' num2str(idx)]);
    %     % alg = params{idx,6}{1};
    % 
    %     % e1 = batch_results{idx,1}.best_objectives(:,1);
    %     % lb1 = batch_results{idx,1}.best_objectives(:,2);
    %     % 
    %     % [pe, he] = ranksum(e0,e1);
    %     % [plb, hlb] = ranksum(lb0, lb1);
    %     % 
    %     % if mean(e0) < mean(e1)
    %     %     e_status = params{j,6}{1};
    %     % elseif mean(e0) == mean(e1)
    %     %     e_status = '?';
    %     % else
    %     %     e_status = alg;
    %     % end
    %     % 
    %     % if mean(lb0) < mean(lb1)
    %     %     lb_status = params{j,6}{1};
    %     % elseif mean(lb0) == mean(lb1)
    %     %     lb_status = '?';
    %     % else
    %     %     lb_status = alg;
    %     % end
    % 
    %     % disp([params{idx,2}{1} char(9) num2str(params{idx,4}) char(9) [params{j,6}{1} '|' alg] char(9) num2str(he) char(9) num2str(hlb) char(9) e_status char(9) lb_status]);
    % end

end

% h = 1 => H0 rejeitada, ou seja, x e y não tem a mesma distribuição, são
% diferentes
% h = 0 => H0 não rejeitada, ou seja, pode ser que x e y tenham a mesma
% distribuição, significancia de 5%


% g = '3x3';
% 
% grids = cell2mat(params{:,2});
% idx = find(grids==g);


