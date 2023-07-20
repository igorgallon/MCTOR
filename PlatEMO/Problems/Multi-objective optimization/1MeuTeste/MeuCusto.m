function [MeuCustoEsult] = MeuCusto(Pop)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[L, R] = size(Pop);
MeuCustoEsult = a;

%Cromossomo
A=[4 0 3 0 2 0 0 1 0];
% Mostra o Cromossomo
B=reshape(A,[3,3])
%Arcos
S=[1 1 2 3];
T=[2 3 4 4];
%Peso de cada arco
P=[10 20 30 40];

% Inicializa os vetores de processadores
sProc=zeros(1,length(S));
tProc=zeros(1,length(T));

%Procura os indices e converte
for i=1:4
    sProc(i)= find(A==S(i));
    tProc(i)= find(A==T(i));
end

%numero de linhas e colunas
nR=3;
nC=3;
% Gera os indices
[LN,CL]=ind2sub([nR nC],1:nR*nC);
Pos_Tab=[LN' CL'];
% Cria uma tabela de distancias
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');
%Inicializa os custos
cost=zeros(1,4);
%Calcula os custos sem peso
for i=1:4
cost(i)=Dist_Tab(sProc(i),tProc(i));    
end

%Calcula os custos com peso (P)
costcompeso=zeros(1,4);
for i=1:4
costcompeso(i)=Dist_Tab(sProc(i),tProc(i))*P(i);    
end
end

