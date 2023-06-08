classdef MCTOR < PROBLEM
% <multi> <integer> <large/none>
% A Framework for Task Routing Optimization in Many-cores Architectures
% nTask --- 5 --- Number of Tasks
% nRow --- 3 --- Number of rows in the Cores Grid
% nCol --- 3 --- Number of columns in the Cores Grid
% S --- 1,1,2,3,3,4 --- List of Tasks IDs (Source)
% T --- 2,3,4,4,5,5 --- List of Tasks IDs (Target)
% W --- 10,20,30,40,50,60 --- List of weights between Gs and Gt
% Enc --- 6 --- Encoding type

%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%------------------------------- Copyright --------------------------------
    properties(Access = private)
        nTask = 5;
        nRow = 3;
        nCol = 3;
        S = [1 1 2 3 3 4];
        T = [2 3 4 4 5 5];
        W = [10 20 30 40 50 60];
        Enc = 6;
    end
    methods
        function Setting(obj)
            [obj.nTask, obj.nRow, obj.nCol, obj.S, obj.T, obj.W, obj.Enc] = obj.ParameterSet();
            % Number of objectives
            if isempty(obj.M); obj.M = 2; end
            % The length of each cromossome is equal to the number of Processors (R x C).
            if isempty(obj.D); obj.D = obj.nRow * obj.nCol; end % Number of decision variables
            % Population size
            if isempty(obj.N); obj.N = 100; end
            obj.encoding = obj.Enc * ones(1, obj.M); % Encoding scheme of each decision variable
            obj.lower = zeros(1, obj.D); % Lower bound of each decision variable
            obj.upper = obj.nTask * ones(1, obj.D); % Upper bound of each decision variable
        end
        
        %% Generate initial solutions
        function Population = Initialization(obj, N)
            if nargin < 2
                N = obj.N;
            end           
            PopDec = MinhaPop(N, obj.nTask, obj.D);
            Population = obj.Evaluation(PopDec);
        end
        
        %% Calculate objective values
        function PopObj = CalObj(obj, PopDec)
            % Inicializa os vetores de processadores
            %sProc=zeros(1,length(S));
            %tProc=zeros(1,length(T));
            %numero de linhas e colunas
            nR=obj.nRow;
            nC=obj.nCol;
            % Gera os indices
            [LN,CL]=ind2sub([nR nC],1:nR*nC);
            Pos_Tab=[LN' CL'];
            % Cria uma tabela de distancias
            Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');

            PopObj = MeuCustoF(PopDec, Dist_Tab, obj.nTask, obj.S, obj.T, obj.W, nR, nC);
        end
    end
end