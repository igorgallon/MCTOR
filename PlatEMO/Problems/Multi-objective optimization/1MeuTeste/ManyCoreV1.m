classdef ManyCoreV1 < PROBLEM
% <multi> <integer> <large/none>
% Many Core Otimization
% nTask --- 5 --- Number of Tasks
% Line --- 3 --- Number of Image
% Column --- 3 --- Number of Image
% S --- 1,1,2,3,3,4 --- Arco do Grafo
% T --- 2,3,4,4,5,5 --- Arco do Grafo
% P --- 10,20,30,40,50,60 --- Pesos por Arco
%

%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
% Inicialize GUI
%--------------------------------------------------------------------------
    properties(Access = private)
        nTask = 5;	% Number of Tasks
        Line = 3;   %Number of Image
        Column = 3; %Number of Image
        S = [1 1 2 3 3 4] % Grafo
        T = [2 3 4 4 5 5] % Grafo
        P = [10 20 30 40 50 60] % Pesos
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.nTask,obj.Line,obj.Column,obj.S,obj.T,obj.P]= obj.ParameterSet(2); 
            if isempty(obj.M); obj.M = 2; end  %Numero de objetivos
            if isempty(obj.D); obj.D = obj.Line*obj.Column; end  %Numero de variaveis
            obj.lower    = zeros(1,obj.D);
            obj.upper    = 1000*ones(1,obj.D);
            obj.encoding = 6*ones(1,obj.D);  %Tipo de operador

        end
        
        %%Initialize pop
        function Population = Initialization(obj,N)
            if nargin < 2; N = obj.N; end
            Tarefas=obj.nTask;
            Tamcrom=obj.Line*obj.Column;
            %zx = randi([0 1],N,obj.D);
            %PopDec = (rand(N,obj.D)-0.5)*2.*randi([0 1],N,obj.D);
            %PopDec = randi(4,N, obj.D);
            %for i=1:N
            %    PopDec(i,:) = randperm(12,12);
            %end
            PopDec = MCPop(N, Tarefas, Tamcrom);
            Population = obj.Evaluation(PopDec);
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            %S=[1 1 2 3]; %Tarefa Origem
            S = obj.S;
            %T=[2 3 4 4]; %Taregfa Destino
            T = obj.T;
            %Peso de cada arco
            %P=[10 20 30 40];
            P = obj.P;
            % Inicializa os vetores de processadores
            %sProc=zeros(1,length(S));
            %tProc=zeros(1,length(T));
            %numero de linhas e colunas
            nR=obj.Line;
            nC=obj.Column;
            % Gera os indices
            [LN,CL]=ind2sub([nR nC],1:nR*nC);
            Pos_Tab=[LN' CL'];
            % Cria uma tabela de distancias
            Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');

            g= MCCusto(PopDec, Dist_Tab, 4, S, T, P,nR, nC);
            
            PopObj = g;

        end
%         %% Generate points on the Pareto front
%         function R = GetOptimum(obj,N)
%             R = UniformPoint(N,obj.M);
%             R = R./repmat(sqrt(sum(R.^2,2)),1,obj.M);
%         end
%         %% Generate the image of Pareto front
%  %       function R = GetPF(obj)
%             if obj.M == 2
%  %               R = obj.GetOptimum(100);
%  %           elseif obj.M == 3
%                 a = linspace(0,pi/2,10)';
%                 R = {sin(a)*cos(a'),sin(a)*sin(a'),cos(a)*ones(size(a'))};
%             else
%                 R = [];
%             end
%         end

    end
end