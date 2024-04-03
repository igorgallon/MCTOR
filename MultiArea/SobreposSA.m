function [sobreposicao] = SobreposSA(NocTotal,DimArea, Posicao)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[linhaaux, colunaaux] = size(NocTotal);
sobreposicao = false;

if linhaaux >= (Posicao(1,1)+DimArea(1,1)-1) && colunaaux >= (Posicao(1,2)+DimArea(2,1)-1)
        % Verifique se os quadrados aleatórios não se sobrepõem
        if ~any(NocTotal(Posicao(1,1):Posicao(1,1)+DimArea(1,1)-1, Posicao(1,2):Posicao(1,2)+DimArea(2,1)-1), 'all')

            sobreposicao = false; % Não há sobreposição, saia do loop
        else
            sobreposicao = true;
        end
        
%         [linha, coluna] = size(NocTotal);
%         
%         if (Posicao(1,1)+DimArea(1,1)) > linha
%             sobreposicao = true;
%         end
%         if Posicao(1,2)+DimArea(2,1) > coluna
%             sobreposicao = true;
%         end
else
    sobreposicao = true;
end
end

