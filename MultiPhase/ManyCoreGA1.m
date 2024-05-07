classdef ManyCoreGA1 < PROBLEM
% <multi> <integer> <large/none>
% Many Core Otimization
% nTask --- 7 --- Number of Tasks
% Line --- 2 --- Number of Image
% Column --- 2 --- Number of Image
% S --- 1,1,1,2,3,4,4,5,6 --- Arco do Grafo
% T --- 2,4,3,4,4,5,6,7,7 --- Arco do Grafo
% P --- 10,20,30,45,55,40,50,60,70 --- Pesos por Arco
%

%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
% Inicialize GUI
%--------------------------------------------------------------------------
    properties(Access = private)
        nTask = 7;	% Number of Tasks
        Line = 2;   %Number of Image
        Column = 2; %Number of Image
        S = [1 1 1 2 3 4 4 5 6] % Grafo
        T = [2 4 3 4 4 5 6 7 7] % Grafo
        P = [10 20 30 45 55 40 50 60 70] % Pesos
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.nTask,obj.Line,obj.Column,obj.S,obj.T,obj.P]= obj.ParameterSet(2); 
            if isempty(obj.M); obj.M = 1; end  %Numero de objetivos
            if isempty(obj.D); obj.D = obj.nTask; end  %Numero de variaveis
            obj.lower    = zeros(1,obj.D);
            obj.upper    = obj.Line*obj.Column*ones(1,obj.D);
            obj.encoding = 9*ones(1,obj.D);  %Tipo de operador

        end
        
        %%Initialize pop
        function Population = Initialization(obj,N)
            if nargin < 2; N = obj.N; end
            Tarefas=obj.nTask;
            Tamcrom=obj.Line*obj.Column;
            
            PopDec = MCMAPopGA(N, Tarefas, Tamcrom);
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

            g= MCMACusto(PopDec, Dist_Tab, nR*nC, S, T, P,nR, nC);
            g1= MCMACustoGA(PopDec, Dist_Tab, nR*nC, S, T, P,nR, nC);
            
            PopObj = g1;

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

