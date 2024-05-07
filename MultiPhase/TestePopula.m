S1 = [1 2 1 3 4 4 2];
T1 = [2 3 4 5 6 7 8];
W1 = [21 42 31 45 49 45 4];

S2 = [1 1 1 2 2 3 5 6 6 6 7 7 8 9 10 10 11];
T2 = [2 3 4 5 6 7 6 4 7 8 9 10 9 10 11 12 12];
W2 = [100 10 200 20 20 20 40 40 40 300 30 30 50 50 50 60 60];

S3 = [1 2 1 3 4 4 2 3];
T3 = [2 3 4 5 6 7 8 6];
W3 = [21 42 31 45 49 45 4 32];

S4 = [1 1 1 2 2 3 5 6 6 6 7 7 8 9 10 10 11 2];
T4 = [2 3 4 5 6 7 6 4 7 8 9 10 9 10 11 12 12 7];
W4 = [100 10 200 20 20 20 40 40 40 300 30 30 50 50 50 60 60 60];

TAG1 = [S1; T1; W1];
TAG2 = [S2; T2; W2];
TAG3 = [S3; T3; W3];
TAG4 = [S4; T4; W4];

numeroApp = 4; %entrar com a quantidade de aplicaçõs
numnNoc  = [8 8]; %tamanho do Noc

tic;
for j=1:2
[resultObj resultCusto squareAreaTotal] = DistriArea(TAG1, TAG2, TAG3, TAG4);


for i=1:numeroApp
    custoTag1 = cell2mat(resultCusto(1,i,:));
    posicaoAux = find(custoTag1 == min(custoTag1),1);
    auxiliarArea = cell2mat(squareAreaTotal(1,i));
    areasMelhor(:,i) = auxiliarArea(1:end,posicaoAux);
    
    auxiliarMap = cell2mat(resultObj(1,i));

    z = auxiliarMap(posicaoAux, 1:end);
    mapMelhor{i} = num2cell(z);

end
 meuEncode = [5, 5, 5, 5, 2, 2, 2];

 

%f1 = @(x)custoTag1(x(1),1) + custoTag2(x(2),1);
%f1 = @(x)MeuCustoSA(custoTag1(x(1),1),custoTag2(x(2),1));
f1 = @(x)MeuCustoSA(areasMelhor, numnNoc, [x(1) x(2) x(3) x(4) x(5) x(6) x(7)]);
%[x(1) x(2) x(3) x(4) x(5) x(6) x(7)]
% Sendo que tem quatro aplicações neste exemplo
% as variáveis de x(1) até x(4) representa a sequencia de aplicações
% a primeira aplicação sempre vai ser alocada no NoC na posição mais a
% esquerda e inferior
% as variáveis x(5) até x(7) representa a posição relativa direita ou
% esquerda, sendo que x(5) é a posição referente a x(2), x(6) para x(2),
% assim por diante
[s1 s2 s3] = platemo('objFcn',f1,'algorithm',@SA,'encoding',meuEncode,'lower',[1, 1, 1, 1, 1, 1, 1],'upper',[4, 4, 4, 4, 2, 2, 2]);
load 'cellCost_Salva.mat' cellCost;
TesteSA{j} = cellCost{1};
MapApp{j} = mapMelhor;
save('TesteSA.mat', 'TesteSA');
save('MapApp.mat', 'MapApp');
 end
disp('Executado!');
disp(['Tempo decorrido: ', num2str(toc), ' segundos']);