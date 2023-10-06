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
            mean_1 = mean(results(:,1));
            std_1 = std(results(:,1));
            mean_2 = mean(results(:,2));
            std_2 = std(results(:,2));
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
                case '6.User-defined 2'
                    encoding = 7;
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
        
            % Set a color map
            plotColors = jet(length(numTasks));

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
                    % p_coord{i,j} = [pos_x];
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
        end
        
        function [coordinates] = drawSolutionDeprecated(app, chromosome, cromId)

            nRows = app.numRows;
            nColumns = app.numColumns;
                        
            % Set up the draw area
            close;
            app.g = figure;
            set(app.g, 'MenuBar', 'none');
            set(app.g, 'ToolBar', 'none');
            set(app.g, 'NumberTitle', 'off', 'Name', ['Solution ', num2str(cromId)]);
            hold on;
            % Get nodes images
            imgActiveNode = imread('active_node.png', 'png');
            imgInactiveNode = imread('inactive_node.png', 'png');
            % Determine the draw area in the graphic
            totalWidth = nColumns*(utils.wProcessor+utils.wPadding);
            totalHeight = nRows*(utils.hProcessor+utils.hPadding);
            % Hide the axis
            set(gca,'YDir','normal');
            axis([0 totalWidth 0 totalHeight]);
            axis off;
            % Convert chromosome to matrix shape
            cromGrid = reshape(chromosome, nColumns, []).';
            
            % Save the coordinates from each processor figure
            coordinates(app.numTasks) = struct();
            % Draw the Processors Grid
            for i = 1:nRows
                pos_y = (nRows+1-i)*(utils.hProcessor+utils.hPadding);
                for j = 1:nColumns
                    pos_x = (j-1)*(utils.wProcessor+utils.wPadding);
                    task_id = cromGrid(i, j);
                    x1 = pos_x;
                    x2 = pos_x+utils.wProcessor;
                    y1 = pos_y;
                    y2 = pos_y-utils.hProcessor;
                    cx = [x1 x2];  % Coordinates x1,x2
                    cy = [y1 y2];  % Coordinates y1,y2
                    p_id = ((i-1)*nColumns)+j;   % Processor ID
                    if task_id == 0
                        % Plot the Router as disabled mode
                        image(cx, cy, imgInactiveNode);
                    else
                        coordinates(task_id).cx = cx;
                        coordinates(task_id).cy = cy;
                        % Plot the Router in the Processors Grid
                        image(cx, cy, imgActiveNode);
                        % Plot the Task ID in the middle of the Router
                        text(x1+(utils.wProcessor/2), y1-(utils.hProcessor/2), num2str(task_id), 'Color', 'black', 'FontSize', utils.taskFontSize);
                    end
                    % Plot the Processor ID
                    text(x1+(utils.wProcessor/5)+0.5, y1-(utils.hProcessor/5)-0.2, num2str(p_id), 'Color', 'black', 'FontSize', utils.pidFontSize);
                end
            end
            
            % Draw the tasks dependencies using arrows
            for i = 1:length(app.sourceIds)
                s = coordinates(app.sourceIds(i));
                t = coordinates(app.targetIds(i));
                x = [(s.cx(1)+s.cx(2))/2 (t.cx(1)+t.cx(2))/2];
                y = [(s.cy(1)+s.cy(2))/2 (t.cy(1)+t.cy(2))/2];
                ha = annotation('arrow');
                ha.Units = 'normalized';
                ha.Parent = app.g.CurrentAxes;
                ha.LineStyle = '--';
                ha.HeadStyle = 'vback3';
                ha.Color = 'red';
                ha.X = x;
                ha.Y = y;
            end
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
            t = app.numTasks;
            % Draw the chromosome solution
            utils.drawSolution(g, r, c, t, chromosomeSelected, idx, false);
            
            % Return the tip info [#Chromosome ID (Energy, FT)]
            txt = ['#' num2str(idx) ' (' num2str(x) ', ' num2str(y) ')'];
        end
        
        %% Initialize and fill up the table with initial information
        function paramObj = initializeTable(app, tableObj)
            addpath(genpath([pwd,'\thirdparty']))

            % Retrieve parameters
            nEnc = app.encodingBatch;
            grid = app.gridSizeBatch;
            pop = app.popSizeBatch;
            mr = app.mutationRateBatch;
            alg = app.algorithmsBatch;
            
            % For each combination the platemo will be called @nExec times
            nExec = app.numExecutions;
            
            % Retrieve the cartesian product between the parameters
            cp = cartprod(pop, mr, 1:height(alg), 1:height(grid));
            
            % Get the total number of combinations
            n = height(cp);
            
            paramObj.n = n;
            paramObj.r = zeros(n,1);
            paramObj.c = zeros(n,1);
            paramObj.pop = zeros(n,1);
            paramObj.mr = zeros(n,1);
            paramObj.alg = cell(n,1);
            
            % Set up Table
            tableObj.ColumnName = {'Grid'; 'Pop.Size'; 'Mut.Rt.'; 'Enc'; 'Algorithm'; 'Status'; 'Energy(Avg/Std)'; 'LoadBal.(Avg/Std)'; 'Select'};
            numCols = 9;
            tableObj.ColumnFormat = {'char','char','char','char','char','char','char','char','logical'};
            tableObj.ColumnEditable = [false false false false false false false false true];
            tableObj.RowName = 'numbered';

            % Initialize Table content
            tableObj.Data = strings([n,numCols]);
            
            % Fill up the Table with initial information
            for i = 1:n
                paramObj.r(i) = grid(cp(i,4),1);
                paramObj.c(i) = grid(cp(i,4),2);
                paramObj.pop(i) = cp(i,1);
                paramObj.mr(i) = cp(i,2);
                paramObj.alg{i,1} = alg{cp(i,3),1};
                sGrid = strcat(num2str(paramObj.r(i)),"x",num2str(paramObj.c(i)));
                energy_avg = "0.0/0.0";
                loadbal_avg = "0.0/0.0";
                tableObj.Data(i,:) = [sGrid, num2str(paramObj.pop(i)), num2str(paramObj.mr(i)), num2str(nEnc), paramObj.alg{i,1}, strcat("0/",num2str(nExec)), energy_avg, loadbal_avg, 0];
            end
        end
        
        %% Retrieve the encoding value according to the selected option in @option
        function encoding = getEncodingTable(option)
            switch option
                case 'grid'
                    encoding = 1;
                case 'pop'
                    encoding = 2;
                case 'mr'
                    encoding = 3;
                case 'enc'
                    encoding = 4;
                case 'alg'
                    encoding = 5;
                case 'status'
                    encoding = 6;
                case 'e'
                    encoding = 7;
                case 'lb'
                    encoding = 8;
                case 'select'
                    encoding = 9;
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
    end
end