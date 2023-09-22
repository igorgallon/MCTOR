classdef tgff
    
    methods(Static)
        
        %% Auxiliar function to extract the tasks from a TGFF file
        function task_obj = extractTask(x, time_labels)
            n = numel(x);
            task_obj.n = n;
            task_obj.id = zeros(n, 1);
            task_obj.type = zeros(n, 1);
            for i = 1:n
                graph_id = str2double(x{1,i}{1,1}) + 1;
                time = time_labels{1,1}.exec_time; % Always considers the TABLE 0
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
                time = time_labels{1,1}.exec_time; % Always considers the TABLE 0

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

        %% Extract meta info from TGFF input file
        function m = extractMetaInfo(input_file)
            rawFile = extractFileText(input_file);
            m.graph_count = str2double(regexp(rawFile, "tg_cnt (\d+)", 'tokens', 'once'));
            m.table_label = regexp(rawFile, "table_label (\w+)", 'tokens', 'once');
            m.table_count = str2double(regexp(rawFile, "table_cnt (\d+)", 'tokens', 'once'));
        end

        %% Convert the Graphs from TGFF format to Source-Target-Weight arrays format
        function [n, s, t, w, nt] = parse(input_file, meta)
            
            rawFile = extractFileText(input_file);
            
            tableLabel = meta.table_label;
        
            f_graph = 'all';
            if meta.graph_count > 1
                f_graph = 'once';
            end

            f_table = 'all';
            if meta.table_count > 1
                f_table = 'once';
            end

            patternSpace = '(?>\s|\t|\n)+';
            patternTaskId = 't\d+_(\d+)';
            patternId = '(\d+)';
            patternFloat = '(\d+[.]\d+)';
            patternWild = '\{(.+)\}';
            patternTask = ['TASK t(\d+)_(\d+)' patternSpace 'TYPE ' patternId];
            patternArc = ['ARC a(\d+)_(\d+)' patternSpace 'FROM ' patternTaskId patternSpace 'TO' patternSpace patternTaskId ' TYPE ' patternId];
            patternHardDeadline = ['HARD_DEADLINE d(\d+)_(\d+)' patternSpace 'ON' patternSpace patternTaskId ' AT ' '(\d+)'];
            patternTimeLabel = '@' + tableLabel + ' ' + patternId + ' ' + patternWild;
            patternLabels = [patternId patternSpace patternFloat patternSpace];
            patternTaskGraph = ['@TASK_GRAPH ' patternId ' ' patternWild];
            
            [graphs] = extract(rawFile, "@TASK_GRAPH " + digitsPattern + " {" + wildcardPattern + "}");
            
            % Extract GRAPH ID and body
            [g] = regexp(graphs, patternTaskGraph, 'tokens', f_graph);
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
            
            % Extract TABLEs
            % [l] = regexp(rawFile, patternTimeLabel, 'tokens', 'all');
            [l] = extract(rawFile, "@" + tableLabel + " " + digitsPattern + " {" + wildcardPattern + "}");
            [labels] = regexp(l, patternTimeLabel, 'tokens', f_table);
            [label_id, label_body] = cellfun(@(x) deal(x{1}, x{2}), labels, 'UniformOutput', false);
            [time_labels] = regexp(label_body, patternLabels, 'tokens', 'all');
        
            graphs_obj.n = n_graphs;
            graphs_obj.labels = cellfun(@tgff.extractTimeLabel, time_labels, 'UniformOutput', false);
            graphs_obj.tasks = cellfun(@(x) tgff.extractTask(x, graphs_obj.labels), tasks, 'UniformOutput', false);
            graphs_obj.arcs = cellfun(@(x) tgff.extractArc(x, graphs_obj.labels), arcs, 'UniformOutput', false);
            graphs_obj.deadlines = cellfun(@tgff.extractDeadline, deadlines, 'UniformOutput', false);
            
            source = [];
            target = [];
            weight = [];
            num_tasks = zeros(n_graphs,1);
            total_tasks = 0;
            
            for i=1:n_graphs
                num_tasks(i) = graphs_obj.tasks{i,1}.n;
                source = [source; graphs_obj.arcs{i,1}.from + total_tasks ];
                target = [target; graphs_obj.arcs{i,1}.to + total_tasks];
                weight = [weight; graphs_obj.arcs{i,1}.type ];
                total_tasks = total_tasks + graphs_obj.tasks{i,1}.n;
            end
            
            n = total_tasks;
            s = source';
            t = target';
            w = weight';
            nt = num_tasks';
        end
    end
end