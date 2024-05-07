
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
multiApp = {TAG1 TAG2 TAG3 TAG4};

numeroApp = 4; %entrar com a quantidade de aplicações

for i = 1 : 2
    AreasBest = AreasApp{i};
    for j = 1 : numeroApp
        nR = AreasBest(1, j);
        nC = AreasBest(2, j);
        map = MapApp{i};
        individuo = cell2mat(map{j});
        if ~isempty (find(individuo > (nC*nR)))
            find(individuo > (nC*nR))
        end
        aplica = cell2mat(multiApp(j));
        S = aplica(1,:);
        T = aplica(2,:);
        P = aplica(3,:);
        
        [LN,CL]=ind2sub([nR nC],1:nR*nC);
        Pos_Tab=[LN' CL'];
        Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');
        [aux, obj, auxFT] = CustoComunicaGA(individuo, Dist_Tab, (nR*nC), S, T, P, nR, nC);
        custo(j) = obj;
        CostFT(j) = auxFT;
        SoluComparaVOPDGA9x9{i,j} = individuo;
    end

    resComparaVOPDGA9x9(i,:) = [custo CostFT];
    
end

csvwrite('SoluComparaVOPDGA9x9.csv', SoluComparaVOPDGA9x9);
csvwrite('resComparaVOPDGA9x9.csv', resComparaVOPDGA9x9);
save SoluComparaVOPDGA9x9.mat;