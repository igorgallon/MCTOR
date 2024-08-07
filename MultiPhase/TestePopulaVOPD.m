%VOPD
S1 = [1    2   3   4  4   5   6   7   8   8   9 10 11 12 12 12  13 14 15 15 16];
T1 = [2    3   4   5 16   6   7   8   9  10  10  9 12  6  9 13  14 15 11 13  5];
W1 = [70 362 362 362 49 357 353 300 313 500 313 94 16 16 16 16 157 16 16 16 27];

%MPEG4
S2 = [  1  1  1   1    1    1   1   2  3  4   5   5   6   6    7   7    8    8    9   9   9    9  10  10  11   12];
T2 = [  2  3  4   5    7    8  10   1  1  1   1   6   5   7    1   6    1    9    8  10  11   12   1   9   9    9];
W2 = [ 64  3  1  20  200  304  11  64  3  1  20  14  14  40  200  40  304  224  224  58  84  167  11  58  84  167];

%VCE
S3 = [1  2  2  3  4  5  6  7    8    8    8    8    9    10   10   11   12 12 13   14   15  15  16  17  18  19  20  22  23   24   25];
T3 = [2  3  4  4  5  6  18 8    9    12   10   11   12   13   24   10   10 16 14   15   16  17  18  22  19  20  21  23  24   25   9];
W3 = [90 90 90 90 30 20 20 8400 2800 2800 2800 5600 2000 4200 4200 1400 30 30 4200 2100 660 660 600 240 620 640 640 240 2210 2280 2280];

%WIFIRX
S4 = [1   1   2   3   4   4 5   6   7   8   9   9   10  11  12 13 14 15  16 17 17 18 18 18 18 18 18 19 19 19 19 19 19];
T4 = [2   6   3   4   5   1 6   7   8   9   10  11  11  12  13 14 15 16  17 18 19 12 13 14 15 16 19 1  9  11 17 18 20];
W4 = [640 640 640 640 640 1 640 640 512 512 384 384 384 384 72 72 72 108 54 6  54 1  1  1  1  1  4  1  1  1  1  1  54];

TAG1 = [S1; T1; W1];
TAG2 = [S2; T2; W2];
TAG3 = [S3; T3; W3];
TAG4 = [S4; T4; W4];

numeroApp = 4; %entrar com a quantidade de aplicações
numnNoc  = [9 9]; %tamanho do Noc

mapMelhor = {1,numeroApp};

tic;
AreaOK = 0;
while AreaOK == 0
    
    [resultObj resultCusto squareAreaTotal] = DistriArea(TAG1, TAG2, TAG3, TAG4);
    
    for i=1:numeroApp
        custoTag1 = cell2mat(resultCusto(1,i,:));
        posicaoAux = find(custoTag1 == min(custoTag1),1);
        auxiliarArea = cell2mat(squareAreaTotal(1,i));
        areasMelhor(:,i) = auxiliarArea(1:end,posicaoAux);
        
        auxiliarMap = cell2mat(resultObj(1,i));
    
        z = auxiliarMap(posicaoAux, 1:end);
    %     if ~isempty (find(z > (areasMelhor(1,i)*areasMelhor(2,i))))
    %         find(z > (areasMelhor(1,i)*areasMelhor(2,i)))
    %     end
        
        mapMelhor{i} = num2cell(z);
        custoMelhor{i} = num2cell(custoTag1(posicaoAux, 1:end));
    end
    
    AreaOK = 1;
    if sum(areasMelhor(1,:) .* areasMelhor(2,:)) > (numnNoc(1) * numnNoc(2))
        AreaOK = 0;
    end
end
meuEncode = [5, 5, 5, 5, 2, 2, 2]; % len = [numApps{enc5}; numApps-1{enc2}]

% upper [numApps{max(numApps)}; numApps-1{2}]

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

% load 'cellCost_Salva.mat' cellCost;
% cellCost =[];

[s1, s2, s3] = platemo('objFcn',f1,'algorithm',@SA,'encoding',meuEncode,'lower',[1, 1, 1, 1, 1, 1, 1],'upper',[4, 4, 4, 4, 2, 2, 2]);
load 'cellCost_Salva.mat' cellCost;
TesteSA{j} = cellCost{1};
MapApp{j} = mapMelhor;
AreasApp{j} = areasMelhor;
CustoApp{j} = custoMelhor;
save('TesteSA.mat', 'TesteSA');
save('MapApp.mat', 'MapApp');
save('AreasApp.mat', 'AreasApp');
save('CustoApp.mat', 'CustoApp');

disp('Executado!');
disp(['Tempo decorrido: ', num2str(toc), ' segundos']);