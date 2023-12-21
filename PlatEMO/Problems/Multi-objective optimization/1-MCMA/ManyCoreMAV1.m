classdef ManyCoreMAV1 < PROBLEM
% <multi> <integer> <large/none>
% Many Core Otimization
% nTask --- 7 --- Number of Tasks
% Line --- 2 --- Number of Image
% Column --- 2 --- Number of Image
% popSize --- 100 --- Population size
% objList --- "E","LB" --- List of objectives
% S --- 1,1,1,2,3,4,4,5,6 --- Arco do Grafo
% T --- 2,4,3,4,4,5,6,7,7 --- Arco do Grafo
% P --- 10,20,30,45,55,40,50,60,70 --- Pesos por Arco
% Enc --- 6 --- Encoding type
% algVar --- 0 --- Algorithm Variation
% mutRate --- 0.01 --- Mutation Rate

%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
% Inicialize GUI
%--------------------------------------------------------------------------
    properties(Access = private)
        nTask = 7;	% Number of Tasks
        Line = 2;   %Number of Image
        Column = 2; %Number of Image
        popSize = 100;    % Population size
        objList = ["E","LB"];      % List of objectives
        S = [1 1 1 2 3 4 4 5 6] % Grafo
        T = [2 4 3 4 4 5 6 7 7] % Grafo
        P = [10 20 30 45 55 40 50 60 70] % Pesos
        Enc = 6;
        algVar = 0;
        mutRate = 0.01;
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.nTask,obj.Line,obj.Column,obj.popSize,obj.objList,obj.S,obj.T,obj.P,obj.Enc,obj.algVar,obj.mutRate]= obj.ParameterSet(2); 
            if isempty(obj.D); obj.D = obj.nTask; end  %Numero de variaveis
            obj.N = obj.popSize;    %Population size
            obj.M = length(obj.objList);    %Number of objectives
            obj.lower    = zeros(1,obj.D);
            obj.upper    = 1000*ones(1,obj.D);
            obj.encoding = obj.Enc*ones(1,obj.D);  %Tipo de operador
        end
        
        %% Initialize pop
        function Population = Initialization(obj, N)
            if nargin < 2; N = obj.N; end

            PopDec = MCMAPopInit(N, obj.nTask, obj.Line, obj.Column, obj.algVar);

            Population = obj.Evaluation(PopDec);
        end
        
        %% Calculate objective values
        function PopObj = CalObj(obj, PopDec)
            
            PopObj = MCMACustoV2(PopDec, obj.S, obj.T, obj.P, obj.Line, obj.Column, obj.objList);

        end

    end
end

