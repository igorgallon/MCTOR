function [n, s, t, w, graphs_obj] = parseTGFF(filePath)
    
    rawFile = extractFileText(filePath);

    patternSpace = '(?>\s|\t)*';
    patternTaskId = 't\d+_(\d+)';
    patternId = '(\d+)';
    patternTask = ['TASK ' patternTaskId patternSpace 'TYPE ' patternId];
    patternArc = ['ARC a\d+_(\d+)' patternSpace 'FROM ' patternTaskId patternSpace 'TO' patternSpace patternTaskId ' TYPE ' patternId];
    patternHardDeadline = ['HARD_DEADLINE d\d+_(\d+)' patternSpace 'ON' patternSpace patternTaskId ' AT ' '(\d+)'];
    patternTaskGraph = ['@TASK_GRAPH ' patternId ' \{(.+)\}'];

    hyperPeriod = regexp(rawFile, ['@HYPERPERIOD ' patternId], 'tokens', 'once');
    [graphs] = extract(rawFile, "@TASK_GRAPH " + digitsPattern + " {" + wildcardPattern + "}");
    
    % Extract GRAPH ID and body
    if(height(graphs) > 1)
        frequency = 'once';
    else
        frequency = 'all';
    end
    [g] = regexp(graphs, patternTaskGraph, 'tokens', frequency);
    [graph_id, graph_body] = cellfun(@(x) deal(x{1}, x{2}), g, 'UniformOutput', false);
    n_graphs = numel(graph_id);

    % Extract TASK ID and TYPE
    [tasks] = regexp(graph_body, patternTask, 'tokens', 'all');
        
    % Extract ARC ID, FROM, TO, and TYPE
    [arcs] = regexp(graph_body, patternArc, 'tokens', 'all');
    
    % Extract HARD_DEADLINE ID, ON, and AT
    [deadlines] = regexp(graph_body, patternHardDeadline, 'tokens', 'all');
    
    graphs_obj.n = n_graphs;
    graphs_obj.tasks = cellfun(@utils.extractTask, tasks, 'UniformOutput', false);
    graphs_obj.arcs = cellfun(@utils.extractArc, arcs, 'UniformOutput', false);
    graphs_obj.deadlines = cellfun(@utils.extractDeadline, deadlines, 'UniformOutput', false);
    
    source = [];
    target = [];
    weight = [];

    for i=1:n_graphs
        source = [source; graphs_obj.arcs{i,1}.from ];
        target = [target; graphs_obj.arcs{i,1}.to ];
        weight = [weight; graphs_obj.arcs{i,1}.type ];
    end
    
    n = max([max(source) max(target)]);
    s = source';
    t = target';
    w = weight';

end