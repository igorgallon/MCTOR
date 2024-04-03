function [perimetro] = CalcPerimetro(nocTeste)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[linha, coluna] = size(nocTeste);
perimetro = 0;

for i=1:linha
    contazeros = find(nocTeste(i, :) == 0);
    for j=1:numel(contazeros)
        if i == 1 && contazeros(j) == 1 
            perimetro = perimetro + ContaProximos(nocTeste, 1, [i contazeros(j)]);
        elseif i == 1 && coluna > contazeros(j) && contazeros(j) > 1
            perimetro = perimetro + ContaProximos(nocTeste, 2, [i contazeros(j)]);
        elseif linha > i && linha > 1 && contazeros(j) == coluna
            perimetro = perimetro + ContaProximos(nocTeste, 3, [i contazeros(j)]);
        elseif linha > i && linha > 1 && contazeros(j) == 1
            perimetro = perimetro + ContaProximos(nocTeste, 4, [i contazeros(j)]);
        elseif i == linha && contazeros(j) == 1
            perimetro = perimetro + ContaProximos(nocTeste, 5, [i contazeros(j)]);
        elseif i == linha && contazeros(j) == coluna
            perimetro = perimetro + ContaProximos(nocTeste, 6, [i contazeros(j)]);
        elseif i == linha && coluna > contazeros(j) && contazeros(j) > 1
            perimetro = perimetro + ContaProximos(nocTeste, 7, [i contazeros(j)]);
        elseif linha > i && linha > 1 && coluna > contazeros(j) && contazeros(j) > 1
            perimetro = perimetro + ContaProximos(nocTeste, 8, [i contazeros(j)]);
        end
    end
end


end

function [auxPerimetro] = ContaProximos(nocTeste, caso, posicao)
    auxPerimetro = 0;
    switch caso
        case 1
            if nocTeste(posicao(1)+1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)+1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
        case 2
            if nocTeste(posicao(1)+1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)+1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)-1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
        case 3
            if nocTeste(posicao(1)+1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)-1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
        case 4
            if nocTeste(posicao(1)+1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1)-1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)+1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
        case 5
            if nocTeste(posicao(1)-1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)+1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
        case 6
            if nocTeste(posicao(1)-1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)-1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
        case 7
            if nocTeste(posicao(1)-1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)-1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)+1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
         case 8
            if nocTeste(posicao(1)+1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1)-1 , posicao(2)) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)-1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
            if nocTeste(posicao(1) , posicao(2)+1) > 0
                auxPerimetro = auxPerimetro + 1;
            end
    end

end

