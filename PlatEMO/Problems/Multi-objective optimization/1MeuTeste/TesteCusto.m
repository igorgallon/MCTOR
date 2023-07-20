Npop = 6;  %Numero de indivíduos
Tarefas = 4; %Numero de tarefas
Tamcrom = 9; % Tamanho do cromossomo
Pesos = [10 20 30 40]; % Peso de cada tarefa

%Entra grafo
%Arcos
S=[1 1 2 3]; %Tarefa Origem
T=[2 3 4 4]; %Taregfa Destino
%Peso de cada arco
P=[10 20 30 40];
% Inicializa os vetores de processadores
sProc=zeros(1,length(S));
tProc=zeros(1,length(T));


%numero de linhas e colunas
nR=Tamcrom^(1/2);
nC=Tamcrom^(1/2);
% Gera os indices
[LN,CL]=ind2sub([nR nC],1:nR*nC);
Pos_Tab=[LN' CL'];
% Cria uma tabela de distancias
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');

%Cria população
Pop = MCPop(Npop, Tarefas, Tamcrom);

b = MCCusto(Pop, Dist_Tab, Tarefas, S, T, Pesos, 3, 3);

c = MeuEApermut(Tarefas,Pop);