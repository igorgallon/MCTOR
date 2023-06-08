classdef ManyCoreV1 < PROBLEM
% <multi> <integer> <large/none>
% Many Core Otimization
% nTask --- 5 --- Number of Tasks
% nRow --- 3 --- Number of Image
% nCol --- 3 --- Number of Image
% S --- 1,1,2,3,3,4 --- Arco do Grafo
% T --- 2,3,4,4,5,5 --- Arco do Grafo
% W --- 10,20,30,40,50,60 --- Pesos por Arco
% Enc --- 6 --- Encoding type

%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
    properties(Access = private)
        nTask = 5;	% Number of Tasks
        nRow = 3;   %Number of Image
        nCol = 3; %Number of Image
        S = [1 1 2 3 3 4]; % Grafo
        T = [2 3 4 4 5 5]; % Grafo
        W = [10 20 30 40 50 60]; % Pesos
        Enc = 6;
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.nTask,obj.nRow,obj.nCol,obj.S,obj.T,obj.W,obj.Enc]= obj.ParameterSet(2); 
            if isempty(obj.M); obj.M = 2; end  %Numero de objetivos
            if isempty(obj.D); obj.D = obj.nRow*obj.nCol; end  %Numero de variaveis
            obj.lower    = zeros(1,obj.D);
            obj.upper    = 1000*ones(1,obj.D);
            obj.encoding = obj.Enc*ones(1,obj.D);  %Tipo de operador

        end
        
        %%Initialize pop
        function Population = Initialization(obj,N)
            if nargin < 2; N = obj.N; end
            PopDec = MinhaPop(N, obj.nTask, obj.D);
            Population = obj.Evaluation(PopDec);
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
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