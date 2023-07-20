classdef MeuTeste3x3 < PROBLEM
% <multi> <integer> <large/none>
% Benchmark MOP with bias feature

%------------------------------- Reference --------------------------------

%--------------------------------------------------------------------------

    methods
        %% Default settings of the problem
        function Setting(obj)
            if isempty(obj.M); obj.M = 2; end  %Numero de objetivos
            if isempty(obj.D); obj.D = 9; end  %Numero de variaveis
            obj.lower    = zeros(1,obj.D);
            obj.upper    = 20*ones(1,obj.D);
            obj.encoding = 5*ones(1,obj.D);  %Tipo de variavel
        end
        
        %%Initialize pop
        function Population = Initialization(obj,N)
            if nargin < 2; N = obj.N; end
            Tarefas=4;
            Tamcrom=9;
            zx = randi([0 1],N,obj.D);
            %PopDec = (rand(N,obj.D)-0.5)*2.*randi([0 1],N,obj.D);
            %PopDec = randi(4,N, obj.D);
            %for i=1:N
            %    PopDec(i,:) = randperm(12,12);
            %end
            PopDec = MinhaPop(N, Tarefas, Tamcrom);
            Population = obj.Evaluation(PopDec);
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            S=[1 1 2 3]; %Tarefa Origem
T=[2 3 4 4]; %Taregfa Destino
%Peso de cada arco
P=[10 20 30 40];
% Inicializa os vetores de processadores
sProc=zeros(1,length(S));
tProc=zeros(1,length(T));


%numero de linhas e colunas
nR=3;
nC=3;
Tarefas = 4;

% Gera os indices
[LN,CL]=ind2sub([nR nC],1:nR*nC);
Pos_Tab=[LN' CL'];
% Cria uma tabela de distancias
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');

            %g      = sum((PopDec(:,obj.M:end)-0.5).^2,2);
            g= MeuCustoF(PopDec, Dist_Tab, Tarefas, S, T, P);
            %PopObj = repmat(1+g,1,obj.M).*fliplr(cumprod([ones(size(g,1),1),cos(PopDec(:,1:obj.M-1)*pi/2)],2)).*[ones(size(g,1),1),sin(PopDec(:,obj.M-1:-1:1)*pi/2)];
            PopObj = g;
        end
        %% Generate points on the Pareto front
        function R = GetOptimum(obj,N)
            R = UniformPoint(N,obj.M);
            R = R./repmat(sqrt(sum(R.^2,2)),1,obj.M);
        end
        %% Generate the image of Pareto front
        function R = GetPF(obj)
            if obj.M == 2
                R = obj.GetOptimum(100);
            elseif obj.M == 3
                a = linspace(0,pi/2,10)';
                R = {sin(a)*cos(a'),sin(a)*sin(a'),cos(a)*ones(size(a'))};
            else
                R = [];
            end
        end
    end
end