%% Collection of utility and helper functions used across the project
classdef utils
    
    properties (Constant)
        
        debugMode = true;   % Enable/disable log in the console

        custom_colormap = [
            1  0  0; % red
            1 .5  0; % orange
            1  1  0; % yellow
            0  1  0; % green
            0  0  1; % blue
        ];
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

        %% Find the best solution by finding the shortest distance
        % between the pair (x,y) and the PF origin (0,0)
        function b = getBestSolution(dec, obj)
            x = obj;
            y = zeros(height(obj), 2);
            % Calculate the euclidean distance
            d = pdist2(x, y, 'fasteuclidean');
            % Find the shortest distance
            [~, idx] = min(d(:,1));
            % Save the best solution
            b.best_result = obj(idx,:);
            b.best_solution = dec(idx,:);
        end

        %% Collects the solution parameters (objective values and chromosome) and 
        % structure them in an array
        % @dec      Population of the last generation
        % @obj      Objective for each individual of the Solution
        % @con      Constraints violation
        function x = structureSolution(dec, obj)
            x.energy = obj(:,1);
            x.fault_tolerance = obj(:,2);
            x.chromosomes = dec;
            x.best = utils.getBestSolution(dec, obj);
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

        %% Represents the chromosome solution in the processors and routers grid
        % @app          App Design object
        % @chromosome   The chromosome solution
        % @cromId       The chromosome ID
        function [coordinates] = drawSolution(app, chromosome, cromId)
            % Define proportional values to draw figures
            hProcessor = 10;    % Processor figure's height
            wProcessor = 10;    % Processor figure's width
            hPadding = 2;       % Height padding between processors
            wPadding = 2;       % Width padding between processors
            hLabel = 2;
            wLabel = 2;
            sizeTaskLabel = 12;
            sizePIDLabel = 8;
            
            nRows = app.numRows;
            nColumns = app.numColumns;
                        
            % Set up the draw area
            close;
            app.g = figure('WindowState', 'maximized');
            set(app.g, 'MenuBar', 'none');
            set(app.g, 'ToolBar', 'none');
            set(app.g, 'NumberTitle', 'off', 'Name', ['Solution ', num2str(cromId)]);
            hold on;
            % Determine the draw area in the graphic
            totalWidth = nColumns*(wProcessor+wPadding);
            totalHeight = nRows*(hProcessor+hPadding);
            % Hide the axis
            set(gca,'YDir','normal');
            axis([0 totalWidth 0 totalHeight]);
            axis off;
        
            % Save the coordinates from each processor figure
            p_coord = cell(nRows, nColumns);
        
            grid = zeros(nRows*nColumns, app.numTasks);
            
            for i=1:app.numTasks
                if ismember(i, chromosome)
                    pid = find(chromosome== i);
                    grid(i,1:length(pid)) = pid;
                end
            end
        
            % Draw the Processors Grid
            for i = 1:nRows
                pos_y = (nRows-i)*(hProcessor+hPadding);
                for j = 1:nColumns
                    pos_x = (j-1)*(wProcessor+wPadding);
                    pid_x = pos_x;
                    pid_y = pos_y+hProcessor-1;
                    p_id = ((i-1)*nColumns)+j;   % Processor ID
                    % p_coord{i,j} = [pos_x];
                    % Draw processor
                    rectangle('Position', [pos_x pos_y wProcessor hProcessor], 'FaceColor', 'none', 'Curvature', 0.1);
                    % Plot the Processor ID
                    text(pid_x, pid_y, num2str(p_id), 'Color', 'black', 'FontSize', sizePIDLabel);
                    % Plot the tasks ids
                    text(pos_x + wProcessor/2, pos_y + hProcessor/2, num2str(nonzeros(grid(p_id,:))), 'HorizontalAlignment', 'center');
                end
            end
        end
        
        function [coordinates] = drawSolutionDeprecated(app, chromosome, cromId)
            % Define proportional values to draw figures
            hProcessor = 10;    % Processor figure's height
            wProcessor = 10;    % Processor figure's width
            hPadding = 5;       % Height padding between processors
            wPadding = 5;       % Width padding between processors
            hLabel = 2;
            wLabel = 2;
            sizeTaskLabel = 12;
            sizePIDLabel = 8;
            
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
            totalWidth = nColumns*(wProcessor+wPadding);
            totalHeight = nRows*(hProcessor+hPadding);
            % Hide the axis
            set(gca,'YDir','normal');
            axis([0 totalWidth 0 totalHeight]);
            axis off;
            % Convert cromossom to matrix shape
            cromGrid = reshape(chromosome, nColumns, []).';
            
            % Save the coordinates from each processor figure
            coordinates(app.numTasks) = struct();
            % Draw the Processors Grid
            for i = 1:nRows
                pos_y = (nRows+1-i)*(hProcessor+hPadding);
                for j = 1:nColumns
                    pos_x = (j-1)*(wProcessor+wPadding);
                    task_id = cromGrid(i, j);
                    x1 = pos_x;
                    x2 = pos_x+wProcessor;
                    y1 = pos_y;
                    y2 = pos_y-hProcessor;
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
                        text(x1+(wProcessor/2), y1-(hProcessor/2), num2str(task_id), 'Color', 'black', 'FontSize', sizeTaskLabel);
                    end
                    % Plot the Processor ID
                    text(x1+(wProcessor/5)+0.5, y1-(hProcessor/5)-0.2, num2str(p_id), 'Color', 'black', 'FontSize', sizePIDLabel);
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
            x_axis = app.solution.energy;
            y_axis = app.solution.fault_tolerance;
            coordinates = [x_axis(:), y_axis(:)];
            idx = find(ismember(coordinates, [x y], 'rows'), 1);
            chromosomeSelected = app.solution.chromosomes(idx, :);
            
            % Draw the chromosome solution
            utils.drawSolution(app, chromosomeSelected, idx);
            
            % Return the tip info [#Chromosome ID (Energy, FT)]
            txt = ['#' num2str(idx) ' (' num2str(x) ', ' num2str(y) ')'];
        end
                
        %% Auxiliar function to extract the tasks from a TGFF file
        function task_obj = extractTask(x, time_labels)
            n = numel(x);
            task_obj.n = n;
            task_obj.id = zeros(n, 1);
            task_obj.type = zeros(n, 1);
            for i = 1:n
                graph_id = str2double(x{1,i}{1,1}) + 1;
                time = time_labels{graph_id,1}.exec_time;
                task_obj.id(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,2}) + 1);
                task_obj.type(i) = time(str2double(x{1,i}{1,3}) + 1);
            end
        end
        
        %% Auxiliar function to extract the arcs from a TGG file
        function arc_obj = extractArc(x, time_labels)
            n = numel(x);
            arc_obj.n = n;
            arc_obj.id = zeros(n, 1);
            arc_obj.from = zeros(n, 1);
            arc_obj.to = zeros(n, 1);
            arc_obj.type = zeros(n, 1);
            for i = 1:n
                graph_id = str2double(x{1,i}{1,1}) + 1;
                time = time_labels{graph_id,1}.exec_time;

                arc_obj.id(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,2}) + 1);
                arc_obj.from(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,3}) + 1);
                arc_obj.to(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,4}) + 1);
                arc_obj.type(i) = time(str2double(x{1,i}{1,5}) + 1);
            end
        end
        
        %% Auxiliar function to extract the deadlines from a TGFF file
        function dl_obj = extractDeadline(x)
            n = numel(x);
            dl_obj.n = n;
            dl_obj.id = zeros(n, 1);
            dl_obj.on = zeros(n, 1);
            dl_obj.at = zeros(n, 1);
            for i = 1:n
                graph_id = str2double(x{1,i}{1,1}) + 1;
                
                dl_obj.id(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,2}) + 1);
                dl_obj.on(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,3}) + 1);
                dl_obj.at(i) = str2double(x{1,i}{1,4});
            end
        end
        
        %% Auxiliar function to extract the time labels from a TGFF file
        function dl_obj = extractTimeLabel(x)
            n = numel(x);
            dl_obj.n = n;
            dl_obj.id = zeros(n, 1);
            dl_obj.exec_time = zeros(n, 1);
            for i = 1:n
                dl_obj.id(i) = str2double(x{1,i}{1,1}) + 1;
                dl_obj.exec_time(i) = round(str2double(x{1,i}{1,2}), 2);
            end
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
            tableObj.ColumnName = {'Grid'; 'Pop.Size'; 'Mut.Rt.'; 'Enc'; 'Algorithm'; 'Status'; 'Energy(Avg/Std)'; 'LoadBal.(Avg/Std)'};
            numCols = 8;
            tableObj.ColumnFormat = {'char'};
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
                tableObj.Data(i,:) = [sGrid, num2str(paramObj.pop(i)), num2str(paramObj.mr(i)), num2str(nEnc), paramObj.alg{i,1}, strcat("0/",num2str(nExec)), energy_avg, loadbal_avg];
            end
        end
        
        %% Update a field from the UITable
        % @table        UITable object
        % @i            Row index to be updated
        % @field        Field name of the row @i
        % @val          The new value to update
        function [] = updateTableByField(table, i, field, val)
            switch field
                case 'grid'
                    idx = 1;
                case 'pop'
                    idx = 2;
                case 'mr'
                    idx = 3;
                case 'alg'
                    idx = 4;
                case 'enc'
                    idx = 5;
                case 'status'
                    idx = 6;
                case 'e'
                    idx = 7;
                case 'lb'
                    idx = 8;
                otherwise
                    idx = 0;
            end

            if idx > 0
                table.Data(i,idx) = val;
            else
                log(['WARNING! Index ' field ' not found in the UITable']);
            end
        end
    end
end