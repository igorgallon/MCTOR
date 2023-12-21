function ft = FaultToleranceCost(ind, r, c)
    nProc = r*c;
    % Discover the idle processors
    idleProc = setdiff(1:nProc, ind);
    if isempty(idleProc)
        ft = intmax;
    else
        % Get the cartesian coordinates in the processors grid to each task id
        taskCoord = utils.getCoordinate(ind, r, c);
        idleCoord = utils.getCoordinate(idleProc, r, c);
        % Retrieve for each task the Manhattan distance between each idle core
        distIdle = pdist2(taskCoord, idleCoord, 'cityblock');
        % Retrieve the worst case
        ft = max(min(distIdle, [], 2));
    end
end

