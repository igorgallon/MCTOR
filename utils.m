%% Collection of utility and helper functions used across the project
classdef utils
    
    properties (Constant)        
        %% Enable/disable log in the console
        debugMode = true;

        %% Chromosome solution displayer constants
        elementsPerLine = 3;
        % Define proportional values to draw figures
        hProcessor = 10;    % Processor figure's height
        wProcessor = 10;    % Processor figure's width
        hPadding = 2;       % Height padding between processors
        wPadding = 2;       % Width padding between processors
        hLabel = 2;
        wLabel = 2;
        taskFontSize = 12;
        pidFontSize = 8;
        pRectangleCurve = 0.1;
        taskFontWeight = 'bold';
        figureBackgroundColor = [0.69, 0.69, 0.69];
        
        %% Options constants
        OBJ_ENERGY = "E";
        OBJ_FAULTTOLERANCE = "FT";
        OBJ_LOADBALANCE = "LB";

        %% Batch table parameters constants
        nTableNumColsEL = 11;
        sTableHeaderEL = {'Input'; 'Approach'; 'Grid'; 'Pop.Size'; 'Mut.Rt.'; 'Algorithm'; 'Status'; 'Energy(Avg/Std)'; 'LoadBal.(Avg/Std)'; 'TTot'; 'Select'};
        sColumnFormatEL = {'char', 'char','char','char','char','char','char','char','char','char','logical'};
        sColumnEditableEL = [false false false false false false false false false false true];
        nTableNumColsEF = 11;
        sTableHeaderEF = {'Input'; 'Approach'; 'Grid'; 'Pop.Size'; 'Mut.Rt.'; 'Algorithm'; 'Status'; 'Energy(Avg/Std)'; 'FaultTol.(Avg/Std)'; 'TTot'; 'Select'};
        sColumnFormatEF = {'char', 'char','char','char','char','char','char','char','char','char','logical'};
        sColumnEditableEF = [false false false false false false false false false false true];
        nTableNumColsELF = 12;
        sTableHeaderELF = {'Input'; 'Approach'; 'Grid'; 'Pop.Size'; 'Mut.Rt.'; 'Algorithm'; 'Status'; 'Energy(Avg/Std)'; 'LoadBal.(Avg/Std)'; 'FaultTol.(Avg/Std)'; 'TTot'; 'Select'};
        sColumnFormatELF = {'char', 'char','char','char','char','char','char','char','char','char','char','logical'};
        sColumnEditableELF = [false false false false false false false false false false false true];
    end
    
    methods(Static)
        
        %% Encapsulate the log calls
        function [] = log(message)
            if utils.debugMode
                disp(message);
            end
        end

        %% Set virtual id for Tasks, Arcs, and Labels from TGFF files
        % @g        Graph id
        % @id       Real id
        % @vid      Virtual id
        function vid = setVirtualId(g, id)
            % vid = (100 * g) + id;
            vid = id;
        end
        
        %% Retrive the virtual id for Tasks, Arcs, and Labels from TGFF file
        % @vid      Virtual id
        % @g        Graph id
        % @id       Real id
        function [g, id] = getRealId(vid)
            % g = fix(vid/100);
            % id = rem(vid/100);
            g = 1;
            id = vid;
        end

        %% Calculate the total time of the grid mapping based on the original
        % graph
        function tTot = getTotalTime(ind, r, c, s, t, w)
            
            nVertex = length(w);
            weightSum = zeros(nVertex);
            
            taskCoord = utils.getCoordinate(ind, r, c);
            
            for i=1:nVertex
                d = pdist2(taskCoord(s(i),:), taskCoord(t(i),:), 'cityblock');
                weightSum(i) = d * w(i);
            end
            
            tTot = sum(weightSum,'all');
        end
        
        function app = initializeApplication(numFiles)
            % Initialize array of structures
            s = struct('applicationName', '', 'numTasks', [], 'sourceIds', [], 'targetIds', [], 'weights', []);
            app = repmat(s, 1, numFiles);
        end

        %% Retrieve the x-y coordinates for each task in the processors grid
        function coord = getCoordinate(ind, r, c)
            x = mod((ind-1),c)+1;
            y = fix((ind-1)/r)+1;
            coord = [x;y]';
        end

        %% Find the best solution by finding the shortest euclidian distance
        % between the pair (x,y) and the Pareto-Front origin (0,0)
        function b = getBestSolution(dec, obj)
            x = obj;
            y = zeros(height(obj), 2);
            % Calculate the euclidean distance
            d = pdist2(x, y);
            % Find the shortest distance
            [min_dist, idx] = min(d(:,1));
            % Save the best solution
            b.index = idx;
            b.all_best_index = find(d(:,1) == min_dist);
            b.best_result = obj(idx,:);
            b.best_solution = dec(idx,:);
        end

        %% Adjust the limits of the graph according to the x and y axis
        % dinamically. The padding window is 10%.
        % @g        Graph object
        % @x        X-Axis
        % @y        Y-Axis
        function [] = setGraphicScale(g, x, y)
            min_x = min(x)*0.9;
            max_x = max(x)*1.1;
            min_y = min(y)*0.9;
            max_y = max(y)*1.1;
            set(g, 'XLim', [min_x max_x], 'YLim', [min_y max_y]);
        end
        
        %% Normalize a given array by the maximum element
        function n = norm(a)
            if a ~= 0
                n = a / max(a);
            else
                n = a;
            end
        end

        %% Collects the solution parameters (objective values and chromosome) and 
        % structure them in an object
        % @dec      Population of the last generation
        % @obj      Objective for each individual of the Solution
        % @con      Constraints violation
        function p = structureSolution(dec, obj)
            p.x_axis = utils.norm(obj(:,1));
            p.y_axis = utils.norm(obj(:,2));
            p.chromosomes = dec;
            p.best = utils.getBestSolution(dec, [p.x_axis p.y_axis]);
        end

        function [n, s, t, w] = concatApps(app)
            n = [];
            s = [];
            t = [];
            w = [];

            for j = 1:length(app.applications)
                n = [n app.applications(j).numTasks];
                s = [s app.applications(j).sourceIds];
                t = [t app.applications(j).targetIds];
                w = [w app.applications(j).weights];
            end
        end

        function [n, s, t, w] = splitApps(app)
            n = {};
            s = {};
            t = {};
            w = {};
            
            % Retrieve the current Application Graphs
            for j = 1:length(app.applications)
                n{1,j} = app.applications(j).numTasks;
                s{1,j} = app.applications(j).sourceIds;
                t{1,j} = app.applications(j).targetIds;
                w{1,j} = app.applications(j).weights;
            end
        end

        %% Collect statistics from batch results
        function [mean_1, std_1, mean_2, std_2, mean_3, std_3, ttot] = getStatistics(objList, results, results_ttot)
            r_1 = results(:,1);
            norm_1 = (r_1 - min(r_1))/(max(r_1) - min(r_1));
            mean_1 = mean(norm_1);
            std_1 = std(r_1);
            
            r_2 = results(:,2);
            % norm_2 = (r_2 - min(r_2))/(max(r_2) - min(r_2));
            mean_2 = mean(r_2);
            std_2 = std(r_2);
            
            ttot = mean(results_ttot);

            if ~isfinite(mean_2) || ~isfinite(std_2)
                disp("Error");
            end
            
            mean_3 = 0;
            std_3 = 0;

            if length(objList) == 3
                r_3 = results(:,3);
                % norm_3 = (r_3 - min(r_3))/(max(r_3) - min(r_3));
                mean_3 = mean(r_3);
                std_3 = std(r_3);
            end
        end
        
        %% Set the axis label string according to the selected objective
        function [] = setAxisLabel(graph, axis, objective)
            
            switch objective
                case utils.OBJ_ENERGY
                    label = "Energy";
                case utils.OBJ_LOADBALANCE
                    label = "Load Balance";
                case utils.OBJ_FAULTTOLERANCE
                    label = "Fault Tolerance";
            end

            if axis == 'x'
                xlabel(graph, label);
            elseif axis == 'y'
                ylabel(graph, label);
            else
                zlabel(graph, label);
            end
        end

        %% Retrieve the objectives value according to the selected option in DropDown
        function objectives = getObjectivesDropDown(option)
            switch option
                case '2.E/LB'
                    objectives = [utils.OBJ_ENERGY, utils.OBJ_LOADBALANCE];
                case '2.E/FT'
                    objectives = [utils.OBJ_ENERGY, utils.OBJ_FAULTTOLERANCE];
                case '3.E/LB/FT'
                    objectives = [utils.OBJ_ENERGY, utils.OBJ_LOADBALANCE, utils.OBJ_FAULTTOLERANCE];
            end
        end

        %% Retrieve the encoding value according to the selected option in DropDown
        function encoding = getEncodingDropDown(option)
            switch option
                case '1.Real'
                    encoding = 1;
                case '2.Integer'
                    encoding = 2;
                case '3.Label'
                    encoding = 3;
                case '4.Binary'
                    encoding = 4;
                case '5.Permutation'
                    encoding = 5;
                case '6.User-defined 1'
                    encoding = 6;
                case '7.User-defined 2'
                    encoding = 7;
            end
        end

        %% Retrieve the algorithm and it variation according to the selected
        % operation in DropDown.The option must follow the pattern {ALGORITHM}_V{VERSION}
        function [algorithm, variation] = getAlgorithmDropDown(option)
            % Split the option by '_'
            name = split(option, '_');
            % Retrieve the first portion as the algorithm name
            algorithm = name{1,1};
            % Retrieve the second portion as the algorithm variation
            if height(name) > 1
                variation = str2double(name{2,1}(2));
            else
                variation = 0;
            end
        end

        %% Retrieve the Application Id based on the task id and the number of tasks
        % for each application
        function idx = getAppId(tid, tasks)
            lastId = 1;
            idx = 0;
            for i=1:length(tasks)
                if tid >= lastId && tid < tasks(i) + lastId
                    idx = i;
                    break;
                end
                lastId = lastId + tasks(i);
            end
        end

        %% Construct a TEX string colorizing each work from @set with a color
        % in @colors
        function str = colorizeText(set, colors)
            str = [];
            for i=1:length(set)
                str = strcat(str,' \color[rgb]{',num2str(colors(i,:)),'}',num2str(set(i)),' ');
                if rem(i,utils.elementsPerLine) == 0
                    str = strcat(str, '\newline');
                end
            end
        end

        %% Represents the chromosome solution in the processors and routers grid
        % @app          App Design object
        % @chromosome   The chromosome solution
        % @cromId       The chromosome ID
        function [] = drawSolution(graph, nRows, nColumns, numTasks, chromosome, cromId, standaloneMode)
            
            utils.log(['Chromosome: ' sprintf('%d ', chromosome)])

            % Set up the draw area
            if standaloneMode
                f = figure('WindowState', 'maximized', 'Color', utils.figureBackgroundColor);
                set(f, 'MenuBar', 'none');
                set(f, 'ToolBar', 'none');
                set(f, 'NumberTitle', 'off', 'Name', ['Solution ', num2str(cromId)]);
            else
                close;
                graph = figure('WindowState', 'maximized', 'Color', utils.figureBackgroundColor);
                set(graph, 'MenuBar', 'none');
                set(graph, 'ToolBar', 'none');
                set(graph, 'NumberTitle', 'off', 'Name', ['Solution ', num2str(cromId)]);
            end
            hold on;

            % Determine the draw area in the graphic
            totalWidth = nColumns*(utils.wProcessor+utils.wPadding);
            totalHeight = nRows*(utils.hProcessor+utils.hPadding);
            % Hide the axis
            set(gca,'YDir','normal');
            axis([0 totalWidth 0 totalHeight]);
            axis off;
            
            n = length(numTasks);

            % Set a color map
            plotColors = jet(n);

            % Save the task ids for each processor element
            nProc = nRows*nColumns;
            nTasks = sum(numTasks);
            tasks = zeros(nProc, nTasks);
            for i=1:nProc
                if ismember(i, chromosome)
                    pid = find(chromosome == i);
                    tasks(i,1:length(pid)) = pid;
                end
            end

            % Draw the Processors Grid
            for i = 1:nRows
                pos_y = (nRows-i)*(utils.hProcessor+utils.hPadding);
                for j = 1:nColumns
                    pos_x = (j-1)*(utils.wProcessor+utils.wPadding);
                    pid_x = pos_x;
                    pid_y = pos_y+utils.hProcessor-1;
                    p_id = ((i-1)*nColumns)+j;   % Processor ID
                    % Draw processor
                    rectangle('Position', [pos_x pos_y utils.wProcessor utils.hProcessor], 'FaceColor', 'none', 'Curvature', utils.pRectangleCurve);
                    % Plot the Processor ID
                    text(pid_x, pid_y, num2str(p_id), 'Color', 'black', 'FontSize', utils.pidFontSize);
                    % Plot the tasks ids
                    taskIds = nonzeros(tasks(p_id,:));
                    if ~isempty(taskIds)
                        appIds = arrayfun(@(x) utils.getAppId(x, numTasks), taskIds);
                        colors = plotColors(appIds,:);
                        t = utils.colorizeText(taskIds, colors);
                        text(pos_x + utils.wProcessor/2,pos_y + utils.hProcessor/2,t,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',utils.taskFontSize,'FontWeight',utils.taskFontWeight);
                    end
                end
            end
            
            % Apply the legend diferentiating each application by color
            l_color = [];
            l_title = [];
            for t = 1:n
                l_color = [l_color, plot(nan, nan, '-o', 'color', plotColors(t,:))];
                l_title = [l_title, strcat("App #",num2str(t))];
            end
            legend(l_color, l_title)
        end

        %% Display the tip box when a point is selected by the user in the PF graph
        % based on the (x,y) mouse cursor coordinates. Once the element is
        % found, the function draws the solution in the processors grid.
        function txt = displaySolutionTip(~, info, app)
            x = info.Position(1);
            y = info.Position(2);
            
            % Get the chromosome selected based on x-y-coordinates
            x_axis = app.solution.x_axis;
            y_axis = app.solution.y_axis;
            coordinates = [x_axis(:), y_axis(:)];
            idx = find(ismember(coordinates, [x y], 'rows'), 1);
            chromosomeSelected = app.solution.chromosomes(idx, :);
            
            g = app.g;
            r = app.numRows;
            c = app.numColumns;
            t = app.applications(1).numTasks;
            % Draw the chromosome solution
            utils.drawSolution(g, r, c, t, chromosomeSelected, idx, false);
            
            % Return the tip info [#Chromosome ID (Energy, FT)]
            txt = ['#' num2str(idx) ' (' num2str(x) ', ' num2str(y) ')'];
        end
        
        %% Initialize and fill up the table with initial information
        function paramObj = initializeTable(app, tableObj)
            addpath(genpath([pwd,'\thirdparty']))

            % Retrieve parameters
            if strcmp(app.applicationMode,'MULTI') || strcmp(app.applicationModeBatch,'MULTI')
                inputs = {'multi apps'};
            else
                inputs = app.inputListBatch;
            end
            grid = app.gridSizeBatch;
            pop = app.popSizeBatch;
            mr = app.mutationRateBatch;
            alg = app.algorithmsBatch;
            approach = app.approachesBatch;
            
            % Retrieve the cartesian product between the parameters
            cp = cartprod(pop, 1:height(approach), mr, 1:height(alg), 1:height(grid), 1:length(inputs));
            
            % Get the total number of combinations
            n = height(cp);
            
            paramObj.appIdx = zeros(n,1);
            paramObj.appName = cell(n,1);
            paramObj.n = n;
            paramObj.r = zeros(n,1);
            paramObj.c = zeros(n,1);
            paramObj.pop = zeros(n,1);
            paramObj.mr = zeros(n,1);
            paramObj.alg = cell(n,1);
            paramObj.approach = cell(n,1);
            
            % Set up Table
            if app.objList(1) == utils.OBJ_ENERGY && app.objList(2) == utils.OBJ_LOADBALANCE
                numCols = utils.nTableNumColsEL;
                tableObj.ColumnName = utils.sTableHeaderEL;
                tableObj.ColumnFormat = utils.sColumnFormatEL;
                tableObj.ColumnEditable = utils.sColumnEditableEL;
            elseif app.objList(1) == utils.OBJ_ENERGY && app.objList(2) == utils.OBJ_FAULTTOLERANCE
                numCols = utils.nTableNumColsEF;
                tableObj.ColumnName = utils.sTableHeaderEF;
                tableObj.ColumnFormat = utils.sColumnFormatEF;
                tableObj.ColumnEditable = utils.sColumnEditableEF;
            else
                numCols = utils.nTableNumColsELF;
                tableObj.ColumnName = utils.sTableHeaderELF;
                tableObj.ColumnFormat = utils.sColumnFormatELF;
                tableObj.ColumnEditable = utils.sColumnEditableELF;
            end
            tableObj.RowName = 'numbered';

            % Initialize Table content
            tableObj.Data = strings([n,numCols]);
            
            % Fill up the Table with initial information
            for i = 1:n
                paramObj.appIdx(i) = cp(i,6);
                paramObj.appName(i) = cellstr(inputs{1,cp(i,6)});
                paramObj.r(i) = grid(cp(i,5),1);
                paramObj.c(i) = grid(cp(i,5),2);
                paramObj.pop(i) = cp(i,1);
                paramObj.mr(i) = cp(i,3);
                paramObj.alg{i,1} = alg{cp(i,4),1};
                paramObj.approach{i,1} = approach{cp(i,2)};
                sGrid = strcat(num2str(paramObj.r(i)),"x",num2str(paramObj.c(i)));
                if length(app.objList(1)) == 3
                    tableObj.Data(i,:) = [paramObj.appName(i), paramObj.approach{i,1}, sGrid, num2str(paramObj.pop(i)), num2str(paramObj.mr(i)), paramObj.alg{i,1}, "Wait", "0.0/0.0", "0.0/0.0", "0.0/0.0", "0", 0];
                else
                    tableObj.Data(i,:) = [paramObj.appName(i), paramObj.approach{i,1}, sGrid, num2str(paramObj.pop(i)), num2str(paramObj.mr(i)), paramObj.alg{i,1}, "Wait", "0.0/0.0", "0.0/0.0", "0", 0];
                end
            end
            % Format parameters to save info
            app.paramsToSave = array2table(tableObj.Data(:,1:5));
            app.paramsToSave.Properties.VariableNames(1:5) = utils.sTableHeaderEL(1:5);
        end
        
        %% Retrieve the encoding value according to the selected option in @option
        function encoding = getEncodingTable(objList, option)
            is_3_obj = length(objList) == 3;

            switch option
                case 'input'
                    encoding = 1;
                case 'approach'
                    encoding = 2;
                case 'grid'
                    encoding = 3;
                case 'pop'
                    encoding = 4;
                case 'mr'
                    encoding = 5;
                case 'alg'
                    encoding = 6;
                case 'status'
                    encoding = 7;
                case 'E'
                    encoding = 8;
                case 'LB'
                    encoding = 9;
                case 'FT'
                    if is_3_obj
                        encoding = 10;
                    else
                        encoding = 9;
                    end
                case 'ttot'
                    if is_3_obj
                        encoding = 11;
                    else
                        encoding = 10;
                    end
                case 'select'
                    if is_3_obj
                        encoding = 12;
                    else
                        encoding = 11;
                    end
                otherwise
                    encoding = 0;
            end
        end

        %% Update a field from the UITable
        % @table        UITable object
        % @i            Row index to be updated
        % @field        Field name of the row @i
        % @val          The new value to update
        function [] = updateTableByField(app, i, field, val)
            idx = utils.getEncodingTable(app.objList, field);
            if idx > 0
                app.UITable.Data(i,idx) = val;
            else
                utils.log(['WARNING! Index ' field ' not found in the UITable']);
            end
        end

        %% Retrieve a value from a given field from the UITable
        % @table        UITable object
        % @i            Row index to be retrieved
        % @field        Field name of the row @i
        % @val          The value retrieved
        function val = getValueTableByField(app, i, field)
            idx = utils.getEncodingTable(app.objList, field);
            if idx > 0
                val = app.UITable.Data(i,idx);
            else
                val = 0;
                utils.log(['WARNING! Index ' field ' not found in the UITable']);
            end
        end

        %% Export the matlab results to readable files
        function [] = exportResults(app, numExecuted)
            sRoot = strcat(app.rootFolder, '/batch/');
            
            if numExecuted > 0
                n = numExecuted;
            else
                n = height(app.batchResults);
            end

            % Create the folder name by adding a timestamp
            sReportFolder = strcat(sRoot,string(datetime('now', 'Format', 'yyyyMMdd_HHmmSS')));
            
            % Create the folder structure
            if ~exist(sRoot, 'dir')
                mkdir(sRoot);
            end
            mkdir(sReportFolder);
            
            % Save the matlab results as-is
            batch_results = app.batchResults;
            save(strcat(sReportFolder,'/results.mat'), "batch_results");
            
            [~, lP] = size(app.paramsToSave);
            objectiveStatistics = cell(n, lP + 2*length(app.objList));
            
            % Convert matlab results to CSV files
            for i=1:n
                writematrix(batch_results{i,1}.best_objectives, strcat(sReportFolder,'/',num2str(i),'_best_objectives.csv'));
                writecell(batch_results{i,1}.best_solutions, strcat(sReportFolder,'/',num2str(i),'_best_solutions.csv'));
                writecell(batch_results{i,1}.best_chromosome, strcat(sReportFolder,'/',num2str(i),'_best_chromosome'));

                for j=1:lP
                    objectiveStatistics{i,j} = app.paramsToSave{i,j};
                end
                objectiveStatistics{i,j+1} = batch_results{i,1}.mean_obj1;
                objectiveStatistics{i,j+2} = batch_results{i,1}.std_obj1;
                objectiveStatistics{i,j+3} = batch_results{i,1}.mean_obj2;
                objectiveStatistics{i,j+4} = batch_results{i,1}.std_obj2;
                if length(app.objList) == 3
                    objectiveStatistics{i,j+5} = batch_results{i,1}.mean_obj3;
                    objectiveStatistics{i,j+6} = batch_results{i,1}.std_obj3;
                    objectiveStatistics{i,j+7} = batch_results{i,1}.mean_ttot;
                else
                    objectiveStatistics{i,j+5} = batch_results{i,1}.mean_ttot;
                end
            end
            
            % Save parameters info to a CSV file
            writetable(app.paramsToSave, strcat(sReportFolder,'/params'));
            writecell(objectiveStatistics, strcat(sReportFolder,'/statistics.csv'));
            utils.log(['Results saved in: ' sReportFolder]);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                          PlatEMO Calls                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Approaches Selector
        function [dec, obj] = callApproachByOption(app, option, params)

            % Add restriction numTasks <= numProc
            switch option
                case 'Multi-Application'
                    [dec, obj] = utils.callMultiApplicationProblem(app, params);
                case 'Simulated Annealing'
                    % Missing @SAPerm Problem
                    [dec, obj] = utils.callSimulatedAnnealingProblem(app, params);
                case 'Multi-Phase'
                    [dec, obj] = utils.callMultiPhaseProblem(app, params);
                case 'Condor'
                    % Index exceeds the number of array elements. Index must not exceed 0.
                    [dec, obj] = utils.callCondorProblem(app, params);
                otherwise
                    [dec, obj] = utils.callMultiApplicationProblem(app, params);
            end
        end

        %% Multi-Application Approach
        function [dec, obj] = callMultiApplicationProblem(app, params)
            func = str2func(params{1,1});
            maxFE = params{1,13};
            if strcmp(app.applicationMode,'MULTI') || strcmp(app.applicationModeBatch,'MULTI')
                [nT, s, t, w] = utils.concatApps(app);
                p = params(1,2:12);
                p{1,1} = sum(nT);
                p{1,6} = s;
                p{1,7} = t;
                p{1,8} = w;
            else
                p = params(1,2:12);
                p{1,1} = sum(params(1,2));
            end
            [dec, obj] = platemo('problem', @ManyCoreMAV1, 'algorithm', func, 'maxFE', maxFE, 'parameter', p, 'save', 0);
        end

        %% Simulated Annealing Approach
        function [dec, obj] = callSimulatedAnnealingProblem(app, params)

            nRow = params{1,3};
            nColumn = params{1,4};
            [nTasks, S, T, W] = utils.concatApps(app);

            encode = 5 * ones(1, sum(nTasks));
            lowerLimit = 1;
            upperLimit = nRow * nColumn * 3;
            f = @(x) MCCustoSA([nRow, nColumn], S, T, W, sum(nTasks), x);

            [dec, obj] = platemo('objFcn', f, 'algorithm', @SAPermut, 'maxFE', params{1,13}, 'encoding', encode, 'lower', lowerLimit, 'upper', upperLimit, 'parameter', nRow*nColumn, 'save', 0);
        end

        %% Multi-Phase Approach
        function [dec, obj] = callMultiPhaseProblem(app, params)
            nTasks = params{1,2};
            nRow = params{1,3};
            nColumn = params{1,4};
            popSize = params{1,5};

            nApps = length(app.applications);
            a = cell(1,nApps);

            for i=1:nApps
                a{i} = [app.applications(i).sourceIds; app.applications(i).targetIds; app.applications(i).weights];
            end

            AreaOK = 0;
            while AreaOK == 0
                
                [resultObj, resultCusto, squareAreaTotal] = DistriAreaV2(a);
                
                for i=1:nApps
                    custoTag1 = cell2mat(resultCusto(1,i,:));
                    posicaoAux = find(custoTag1 == min(custoTag1),1);
                    auxiliarArea = cell2mat(squareAreaTotal(1,i));
                    areasMelhor(:,i) = auxiliarArea(1:end,posicaoAux);
                    auxiliarMap = cell2mat(resultObj(1,i));
                    z = auxiliarMap(posicaoAux, 1:end);                    
                    mapMelhor{i} = num2cell(z);
                    custoMelhor{i} = num2cell(custoTag1(posicaoAux, 1:end));
                end
                AreaOK = 1;
                if sum(areasMelhor(1,:) .* areasMelhor(2,:)) > (nRow * nColumn)
                    AreaOK = 0;
                end
            end
            
            encode = [ones(1,nApps) * 5, ones(1,nApps-1) * 2];
            lower = ones(1, (2 * nApps) - 1);
            upper = [ones(1, nApps) * nApps, ones(1,nApps-1) * 2];

            f = @(x) MeuCustoSAV2(areasMelhor, [nRow nColumn], x);

            [dec, obj] = platemo('objFcn', f, 'algorithm', @SA, 'maxFE', params{1,13}, 'encoding', encode, 'lower', lower, 'upper', upper, 'save', 0);
        end
        
        %% Condor Approach
        function [dec, obj] = callCondorProblem(app, params)
            rDP = 0.5;   % pct da pop que vai sofrer mutação
            rPC = 0.05;  % quanto incrementa/decrementa DP ao longo das gen
            inferiorDP = 0.1;
            superiorDP = 0.9;
            
            nTasks = params{1,2};
            nRow = params{1,3};
            nColumn = params{1,4};
            popSize = params{1,5};
            S = params{1,7};
            T = params{1,8};
            W = params{1,9};
            maxFE = params{1,13};
            
            [dec, obj] = algoACA(popSize,20, inferiorDP, superiorDP, rDP, rPC, nRow, nColumn, S, T, W);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                   Engineered Mapping Algorithms                 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %% Horizontal raster
        function out = horizontalRaster(r, c, m)
            out = [];
            for i=1:r
                out = [out m(i,:)];
            end
        end
        
        %% Horizontal snake
        function out = horizontalSnake(r, c, m)
            out = [];
            invert = false;
            for i=1:r
                d = m(i,:);
                if invert
                    d = flipud(d(:)).';
                end
                out = [out d];
                invert = ~invert;
            end
        end
        
        %% Diagonal raster
        function out = diagonalRaster(r, c, m)
            out = [];
            for i=-(r-1):(c-1)
              d = diag(flipud(m),i).';
              out = [out d];
            end
        end
        
        %% Diagonal snake
        function out = diagonalSnake(r, c, m)
            out = [];
            invert = false;
            for i=-(r-1):(c-1)
              if invert
                d = flipud(diag(flipud(m),i)).';
              else
                d = diag(flipud(m),i).';
              end
              invert = ~invert;
              out = [out d];
            end
        end

    end
end