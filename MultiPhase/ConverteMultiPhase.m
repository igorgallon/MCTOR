%Converte os resultados do Multi-Phase para equivalente
%Por Manoel Aranda de Almeida
%01/04/2024

%TesteSA1 = load('TesteSA.mat');
%MapApp1 = load('MapApp.mat');

%[NumSol, NumApp] = size(SoluComparaVOPDGA9x9);
MapApp = mapMelhor;
> TesteSA
> AreasApp

[NumSol, NumApp] = size(MapApp);

auxSoluc = [];

for k = 1 : NumApp
    auxSoluc1 = MapApp{k};
    for h = 1 : 4
        auxiliar = cell2mat(auxSoluc1{h});
        auxSoluc{k, h} = auxiliar;
    end
end

[NumSol, NumApp] = size(auxSoluc);
AuxTamApp = zeros(1,NumApp+1);
IndivConv = [];

for j =1 : NumSol
    AuxConvert= TesteSA{j};
    AuxArea = AreasApp{j};
    for p = 2 : NumApp + 1
        if p == 2
            AuxTamApp(p) = length(auxSoluc{j,p-1});
        else
            AuxTamApp(p) = length(auxSoluc{j,p-1})+AuxTamApp(p-1);
        end
end


AreasMP = AuxConvert{3};

[AuxLinha, AuxColuna] = size(AreasMP);
auxPosConv = ones(1,4);
auxPosIndiv = 1;
AuxConvInd = [];
auxIndivConv = [];



for m = 1 : AuxLinha
    for n = 1 : AuxColuna
        if AreasMP(m,n)>0
            
            auxConv = auxSoluc{j,AreasMP(m,n)};
            auxPosiTask = find(auxConv==(auxPosConv(AreasMP(m,n))),1);
            if isempty(find(auxConv==(auxPosConv(AreasMP(m,n))), 1))
                AuxConvInd(m, n) = 0;
            else
                AuxConvInd(m, n) = auxConv(auxPosConv(AreasMP(m,n))) + AuxTamApp(AreasMP(m,n));
            end
            auxPosConv(AreasMP(m,n)) = auxPosConv(AreasMP(m,n)) + 1;
        else
            AuxConvInd(m, n) = 0;
        end
        auxIndivConv(auxPosIndiv) = AuxConvInd(m, n);
        auxPosIndiv = auxPosIndiv + 1;
    end
end
if j == 19
    Iauxiliarz = find(auxIndivConv==d);
end

for d = 1 : max(auxIndivConv)
    if ~isempty(find(auxIndivConv==d,1)) 
        IndivConv(j,d) = find(auxIndivConv==d,1);
    end
end
if find(IndivConv(j,:) == 0)
    Iauxiliarz = find(auxIndivConv==d);
end
end