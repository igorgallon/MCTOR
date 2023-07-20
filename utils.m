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
        
        %% Retrive the virtual id for Tasks, Arcs, and Lavels from TGFF files
        % @vid      Virtual id
        % @g        Graph id
        % @id       Real id
        function [g, id] = getRealId(vid)
            % g = fix(vid/100);
            % id = rem(vid/100);
            g = 1;
            id = vid;
        end

        %% Collects the solution parameters (objective values and cromossome) and structure them in an array
        % @dec      Population of the last generation
        % @obj      Objective for each individual of the Solution
        % @con      Constraints violation
        function x = structureSolution(dec, obj, con)
            x.fault_tolerance = obj(:,1);
            x.energy = obj(:,2);
            x.cromossomes = dec;
        end
        
        %% Represents the cromossome solution in the processors and routers grid
        % @app          App Designed object
        % @cromossome   The cromossome solution
        % @cromId       The cromossome ID
        function [coordinates] = drawSolution(app, cromossome, cromId)
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
            cromGrid = reshape(cromossome, nColumns, []).';
            
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
        function txt = displaySolutionTip(~, info, app)
            x = info.Position(1);
            y = info.Position(2);
            
            % Get the cromossome selected based on x-y-coordinates
            x_axis = app.solution.energy;
            y_axis = app.solution.fault_tolerance;
            coordinates = [x_axis(:), y_axis(:)];
            idx = find(ismember(coordinates, [x y], 'rows'), 1);
            cromossomeSelected = app.solution.cromossomes(idx, :);
            % Draw the cromossome solution
            utils.drawSolution(app, cromossomeSelected, idx);
            % Return the tip info [#Cromossome ID (Energy, FT)]
            txt = ['#' num2str(idx) ' (' num2str(x) ', ' num2str(y) ')'];
        end
        
        %% Get the element selected by the user in the results graph
        % based on the (x,y) mouse cursor coordinates. Once the element is
        % found, the function draws the solution in the processors grid.
        function [] = getSelectedPoint(app, event)
            x_axis = app.solution.energy;
            y_axis = app.solution.fault_tolerance;

            pt = event.IntersectionPoint(1:2);
            coordinates = [x_axis(:), y_axis(:)];
            dist = pdist2(pt, coordinates);
            [~, minIdx] = min(dist);
            pointSelected = coordinates(minIdx, :);
            cromossomeSelected = app.solution.cromossomes(minIdx, :);
            
            log(['[',num2str(pointSelected(1)),',',num2str(pointSelected(2)),']']);
            log(['Cromossome selected: ', num2str(cromossomeSelected)]);
            
            utils.drawSolution(app, cromossomeSelected, minIdx);
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
    end
end