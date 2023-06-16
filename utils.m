classdef utils
    methods(Static)
        
        % Collects the solution parameters (objective values and
        % cromossome) and structure them in an array
        % @dec      Population of the last generation
        % @obj      Objective for each individual of the Solution
        % @con      Constraints violation
        function x = structureSolution(dec, obj, con)
            x.energy = obj(:,1);
            x.fault_tolerance = obj(:,2);
            x.cromossomes = dec;
        end
        
        % Represents the cromossome solution in the processors and routers
        % grid.
        % @app          App Designed object
        % @cromossome   The cromossome solution
        function [] = drawSolution(app, cromossome, cromId)
            % Define proportional values to draw figures
            hProcessor = 10;
            wProcessor = 10;
            hPadding = 5;
            wPadding = 5;
            hLabel = 2;
            wLabel = 2;
            sizeTaskLabel = 12;
            sizePIDLabel = 8;
            
            nRows = app.numRows;
            nColumns = app.numColumns;
            
            % Close previous opened figure
  
            
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
            set(gca,'YDir','reverse');
            axis([0 totalWidth 0 totalHeight]);
            axis off;
            % Convert cromossom to matrix shape
            cromGrid = reshape(cromossome, nColumns, []).';
            p_id = 1;   % Processor ID
            % Draw the Processors Grid
            for i = 1:nRows
                pos_y = (i-1)*(hProcessor+hPadding);
                for j = 1:nColumns
                    pos_x = (j-1)*(wProcessor+wPadding);
                    task_id = cromGrid(i, j);
                    x = [pos_x pos_x+hProcessor];
                    y = [pos_y pos_y+wProcessor];
                    if task_id == 0
                        % Plot the Router as disabled mode
                        image(x, y, imgInactiveNode);
                    else
                        % Plot the Router in the Processors Grid
                        image(x, y, imgActiveNode);
                        % Plot the Task ID in the middle of the Router
                        text(pos_x+(hProcessor/2), pos_y+(wProcessor/2), num2str(task_id), 'Color', 'black', 'FontSize', sizeTaskLabel);
                    end
                    % Plot the Processor ID
                    text(pos_x+(hProcessor/5)+0.5, pos_y+(wProcessor/5)+0.2, num2str(p_id), 'Color', 'black', 'FontSize', sizePIDLabel);
                    p_id = p_id + 1;
                end
            end
        end
        
        function txt = displaySolutionTip(~, info, app)
            x = info.Position(1);
            y = info.Position(2);
            
            % Get the cromossome selected
            x_axis = app.solution.energy;
            y_axis = app.solution.fault_tolerance;
            coordinates = [x_axis(:), y_axis(:)];
            idx = find(ismember(coordinates, [x y], 'rows'), 1);
            cromossomeSelected = app.solution.cromossomes(idx, :);
            %disp(['[',num2str(pointSelected(1)),',',num2str(pointSelected(2)),']']);
            % disp(['Cromossome selected: ', num2str(cromossomeSelected)]);
            utils.drawSolution(app, cromossomeSelected, idx);
            txt = ['#' num2str(idx) ' (' num2str(x) ', ' num2str(y) ')'];
        end

        function [] = getSelectedPoint(app, event)

            x_axis = app.solution.energy;
            y_axis = app.solution.fault_tolerance;

            pt = event.IntersectionPoint(1:2);
            coordinates = [x_axis(:), y_axis(:)];
            dist = pdist2(pt, coordinates);
            [~, minIdx] = min(dist);
            pointSelected = coordinates(minIdx, :);
            cromossomeSelected = app.solution.cromossomes(minIdx, :);
            
            disp(['[',num2str(pointSelected(1)),',',num2str(pointSelected(2)),']']);
            disp(['Cromossome selected: ', num2str(cromossomeSelected)]);
            
            utils.drawSolution(app, cromossomeSelected, minIdx);
        end
        
    end
end