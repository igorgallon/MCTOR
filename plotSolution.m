function [] = plotSolution(nRows, nColumns, cromossome)
    
    % Define proportional values to draw figures
    hProcessor = 10;
    wProcessor = 10;
    hPadding = 5;
    wPadding = 5;
    hLabel = 2;
    wLabel = 2;
    sizeTaskLabel = 12;
    sizePIDLabel = 8;

    % Set up the draw area
    g = figure;
    set(g, 'MenuBar', 'none');
    set(g, 'ToolBar', 'none');
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
    cromGrid = reshape(cromossome, [nRows, nColumns])';
    
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