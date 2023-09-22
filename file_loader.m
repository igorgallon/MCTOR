classdef file_loader
    
    methods(Static)
        
        %% Auxiliar function to Source-Target-Weight from a APP file
        function [s, t, w] = extractArc(x)
            n = numel(x);

            s = zeros(n, 1);
            t = zeros(n, 1);
            w = zeros(n, 1);
            for i = 1:n
                graph_id = str2double(x{1,i}{1,1}) + 1;
                time = time_labels{1,1}.exec_time; % Always considers the TABLE 0

                arc_obj.id(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,2}) + 1);
                arc_obj.from(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,3}) + 1);
                arc_obj.to(i) = utils.setVirtualId(graph_id, str2double(x{1,i}{1,4}) + 1);
                arc_obj.type(i) = time(str2double(x{1,i}{1,5}) + 1);
            end
        end

        %% Convert the Graphs from APP format to Source-Target-Weight arrays format
        function [n, s, t, w, nt] = parse(file)
            
            rawFile = extractFileText(file);

            patternInt = '(\d+)';
            patternFloat = '(\d+\.?\d*)';
            patternSpace = '(?>\s|\t)+';
            patternNumberOfTasks = [patternInt '[\n]+'];
            patternBandwidth = [patternInt patternSpace patternInt patternSpace patternFloat];
            
            numTasks = regexp(rawFile, patternNumberOfTasks, 'tokens', 'once');
            [bandwidths] = regexp(rawFile, patternBandwidth, 'tokens', 'all');
            
            [source, target, weight] = cellfun(@(x) deal(str2double(x{1})+1, str2double(x{2})+1, str2double(x{3})), bandwidths, 'UniformOutput', false);
            
            s = [];
            t = [];
            w = [];
            
            for i=1:length(source)
                s = [s, source{1,i}];
                t = [t, target{1,i}];
                w = [w, weight{1,i}];
            end
            n = 1;
            % s = source;
            % t = target;
            % w = weight;
            nt = str2double(numTasks);
        end
    end
end