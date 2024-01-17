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
        sTableHeader = {'Input'; 'Grid'; 'Pop.Size'; 'Mut.Rt.'; 'Enc'; 'Algorithm'; 'Status'; 'Energy(Avg/Std)'; 'LoadBal.(Avg/Std)'; 'Select'};
        nTableNumCols = 10;
        sColumnFormat = {'char', 'char','char','char','char','char','char','char','char','logical'};
        sColumnEditable = [false false false false false false false false false true];
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
        

        function coord = getCoordinate(n, r, c)
            x = mod((n-1),c)+1;
            y = fix((n-1)/r)+1;
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
            max_x = max(x);
            min_y = min(y)*0.9;
            max_y = max(y);
            set(g, 'XLim', [0 max_x], 'YLim', [0 max_y]);
        end

        function n = norm(a)
            % n1 = a - min(a);
            n = a / max(a);
            % n = a;
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
        
        %% Collect statistics from batch results
        function [mean_1, std_1, mean_2, std_2] = getStatistics(results)
            r_1 = results(:,1);
            r_2 = results(:,2);

            norm_1 = (r_1 - min(r_1))/(max(r_1) - min(r_1));
            norm_2 = (r_2 - min(r_2))/(max(r_2) - min(r_2));

            mean_1 = mean(norm_1);
            std_1 = std(norm_1);

            mean_2 = mean(norm_2);
            std_2 = std(norm_2);
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
            inputs = app.inputListBatch;
            nEnc = app.encodingBatch;
            grid = app.gridSizeBatch;
            pop = app.popSizeBatch;
            mr = app.mutationRateBatch;
            alg = app.algorithmsBatch;
            
            % For each combination the platemo will be called @nExec times
            nExec = app.numExecutions;
            
            % Retrieve the cartesian product between the parameters
            cp = cartprod(pop, mr, 1:height(alg), 1:height(grid), 1:length(inputs));
            
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
            
            % Set up Table
            tableObj.ColumnName = utils.sTableHeader;
            numCols = utils.nTableNumCols;
            tableObj.ColumnFormat = utils.sColumnFormat;
            tableObj.ColumnEditable = utils.sColumnEditable;
            tableObj.RowName = 'numbered';

            % Initialize Table content
            tableObj.Data = strings([n,numCols]);
            
            % Fill up the Table with initial information
            for i = 1:n
                paramObj.appIdx(i) = cp(i,5);
                paramObj.appName(i) = cellstr(inputs{1,cp(i,5)});
                paramObj.r(i) = grid(cp(i,4),1);
                paramObj.c(i) = grid(cp(i,4),2);
                paramObj.pop(i) = cp(i,1);
                paramObj.mr(i) = cp(i,2);
                paramObj.alg{i,1} = alg{cp(i,3),1};
                sGrid = strcat(num2str(paramObj.r(i)),"x",num2str(paramObj.c(i)));
                energy_avg = "0.0/0.0";
                loadbal_avg = "0.0/0.0";
                tableObj.Data(i,:) = [paramObj.appName(i), sGrid, num2str(paramObj.pop(i)), num2str(paramObj.mr(i)), num2str(nEnc), paramObj.alg{i,1}, "Wait", energy_avg, loadbal_avg, 0];
            end
            % Format parameters to save info
            app.paramsToSave = array2table(tableObj.Data(:,1:6));
            app.paramsToSave.Properties.VariableNames(1:6) = utils.sTableHeader(1:6);
        end
        
        %% Retrieve the encoding value according to the selected option in @option
        function encoding = getEncodingTable(option)
            switch option
                case 'input'
                    encoding = 1;
                case 'grid'
                    encoding = 2;
                case 'pop'
                    encoding = 3;
                case 'mr'
                    encoding = 4;
                case 'enc'
                    encoding = 5;
                case 'alg'
                    encoding = 6;
                case 'status'
                    encoding = 7;
                case 'e'
                    encoding = 8;
                case 'lb'
                    encoding = 9;
                case 'select'
                    encoding = 10;
                otherwise
                    encoding = 0;
            end
        end

        %% Update a field from the UITable
        % @table        UITable object
        % @i            Row index to be updated
        % @field        Field name of the row @i
        % @val          The new value to update
        function [] = updateTableByField(table, i, field, val)
            idx = utils.getEncodingTable(field);
            if idx > 0
                table.Data(i,idx) = val;
            else
                log(['WARNING! Index ' field ' not found in the UITable']);
            end
        end

        %% Retrieve a value from a given field from the UITable
        % @table        UITable object
        % @i            Row index to be retrieved
        % @field        Field name of the row @i
        % @val          The value retrieved
        function val = getValueTableByField(table, i, field)
            idx = utils.getEncodingTable(field);
            if idx > 0
                val = table.Data(i,idx);
            else
                val = 0;
                log(['WARNING! Index ' field ' not found in the UITable']);
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
                objectiveStatistics{i,j+1} = batch_results{i,1}.mean_energy;
                objectiveStatistics{i,j+2} = batch_results{i,1}.std_energy;
                objectiveStatistics{i,j+3} = batch_results{i,1}.mean_loadbalance;
                objectiveStatistics{i,j+4} = batch_results{i,1}.std_loadbalance;
            end
            
            % Save parameters info to a CSV file
            writetable(app.paramsToSave, strcat(sReportFolder,'/params'));
            writecell(objectiveStatistics, strcat(sReportFolder,'/statistics.csv'));
            utils.log(['Results saved in: ' sReportFolder]);
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