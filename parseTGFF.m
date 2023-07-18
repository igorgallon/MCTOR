function [n, s, t, w, graphs_obj] = parseTGFF(filePath)
    
    rawFile = extractFileText(filePath);

    patternSpace = '(?>\s|\t|\n)+';
    patternTaskId = 't\d+_(\d+)';
    patternId = '(\d+)';
    patternFloat = '(\d+[.]\d+)';
    patternWild = '\{(.+)\}';
    patternTask = ['TASK t(\d+)_(\d+)' patternSpace 'TYPE ' patternId];
    patternArc = ['ARC a(\d+)_(\d+)' patternSpace 'FROM ' patternTaskId patternSpace 'TO' patternSpace patternTaskId ' TYPE ' patternId];
    patternHardDeadline = ['HARD_DEADLINE d(\d+)_(\d+)' patternSpace 'ON' patternSpace patternTaskId ' AT ' '(\d+)'];
    patternTimeLabel = ['@COMMUN ' patternId ' ' patternWild];
    patternLabels = [patternId patternSpace patternFloat patternSpace];
    patternTaskGraph = ['@TASK_GRAPH ' patternId ' ' patternWild];
    
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

    % Extract HYPERPERIOD label
    hyperPeriod = regexp(rawFile, ['@HYPERPERIOD ' patternId], 'tokens', 'once');

    % Extract TASK ID and TYPE
    [tasks] = regexp(graph_body, patternTask, 'tokens', 'all');
        
    % Extract ARC ID, FROM, TO, and TYPE
    [arcs] = regexp(graph_body, patternArc, 'tokens', 'all');
    
    % Extract HARD_DEADLINE ID, ON, and AT
    [deadlines] = regexp(graph_body, patternHardDeadline, 'tokens', 'all');
    
    % Extract COMMUN
    % [l] = regexp(rawFile, patternTimeLabel, 'tokens', 'all');
    [l] = extract(rawFile, "@COMMUN " + digitsPattern + " {" + wildcardPattern + "}");
    [labels] = regexp(l, patternTimeLabel, 'tokens', frequency);
    [label_id, label_body] = cellfun(@(x) deal(x{1}, x{2}), labels, 'UniformOutput', false);
    [time_labels] = regexp(label_body, patternLabels, 'tokens', 'all');

    graphs_obj.n = n_graphs;
    graphs_obj.labels = cellfun(@utils.extractTimeLabel, time_labels, 'UniformOutput', false);
    graphs_obj.tasks = cellfun(@(x) utils.extractTask(x, graphs_obj.labels), tasks, 'UniformOutput', false);
    graphs_obj.arcs = cellfun(@(x) utils.extractArc(x, graphs_obj.labels), arcs, 'UniformOutput', false);
    graphs_obj.deadlines = cellfun(@utils.extractDeadline, deadlines, 'UniformOutput', false);
    
    source = [];
    target = [];
    weight = [];
    total_tasks = 0;

    for i=1:n_graphs
        total_tasks = max([total_tasks graphs_obj.tasks{i,1}.n]);
        source = [source; graphs_obj.arcs{i,1}.from ];
        target = [target; graphs_obj.arcs{i,1}.to ];
        weight = [weight; graphs_obj.arcs{i,1}.type ];
    end
    
    n = total_tasks;
    s = source';
    t = target';
    w = weight';

end