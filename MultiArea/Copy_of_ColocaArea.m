function [auxiliarCore,resultCusto] = ColocaArea(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

numApp = numel(varargin);

for i = 1:numApp
    if i == numApp
        result = varargin{i};
    else if i == numApp - 1
            auxiliarDim = varargin{i};
        else
            areasAtuais{i} = varargin{i};
        end

    end
end

auxiliarCore = zeros(auxiliarDim);
auxiliarArea = cell2mat(areasAtuais{1});
auxiliarCusto = 0;

save('result_salva.mat', 'result');
save('auxiliarArea_salva.mat', 'auxiliarArea');

for j = 1:numel(result)
    if ~isempty(find(result == 0,1)) || ~isempty(find(result > ((numel(result)-1)/2)+1,1))
        [linha, coluna] = size(auxiliarCore);
        resultCusto = linha * coluna * 100;
        break
    end
    if j == 1 && SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[1 1]) == false
        auxiliarCore(1:auxiliarArea(1,result(j)),1:auxiliarArea(2,result(j))) = result(j);
    else if mod(j,2) == 0
                direita = result(j);
        else
            [linhalivre, colunalivre] = find(auxiliarCore==0);
            if direita == 2
                posicao = find(linhalivre==(min(linhalivre)),1);
                auxiliarCusto = SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[linhalivre(posicao) colunalivre(posicao)]);
                if auxiliarCusto == false
                auxiliarCore(linhalivre(posicao):linhalivre(posicao)+auxiliarArea(1,result(j))-1,colunalivre(posicao):colunalivre(posicao)+auxiliarArea(2,result(j))-1)=result(j);
                else
                    auxiliarDiag = find(diag(auxiliarCore)==0);
                    posicao = find(linhalivre==auxiliarDiag(1),1);
                    auxiliarCusto = SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[linhalivre(find(linhalivre==(min(linhalivre)),1)) colunalivre(posicao)]);
                    if auxiliarCusto == false
                        auxiliarCore(linhalivre(find(linhalivre==(min(linhalivre)),1)):linhalivre(find(linhalivre==(min(linhalivre)),1))+auxiliarArea(1,result(j))-1,colunalivre(posicao):colunalivre(posicao)+auxiliarArea(2,result(j))-1)=result(j);
                    else
                        posicao = find(linhalivre==auxiliarDiag(2),1);
                        auxiliarCusto = SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[linhalivre(find(linhalivre==(min(linhalivre)),1)) colunalivre(posicao)]);
                        if auxiliarCusto == false
                            auxiliarCore(linhalivre(find(linhalivre==(min(linhalivre)),1)):linhalivre(find(linhalivre==(min(linhalivre)),1))+auxiliarArea(1,result(j))-1,colunalivre(posicao):colunalivre(posicao)+auxiliarArea(2,result(j))-1)=result(j);
                        end
                    end
                end
            else
                posicao = find(colunalivre==(min(colunalivre)),1); % excede aqui
                auxiliarCusto = SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[linhalivre(posicao) colunalivre(posicao)]);
                if auxiliarCusto == false
                    auxiliarCore(linhalivre(posicao):linhalivre(posicao)+auxiliarArea(1,result(j))-1,colunalivre(posicao):colunalivre(posicao)+auxiliarArea(2,result(j))-1)=result(j);
                else                    
                    auxiliarDiag = find(diag(auxiliarCore)==0);
                    posicao = find(colunalivre==auxiliarDiag(1),1);
                    auxiliarCusto = SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[linhalivre(find(linhalivre==(min(linhalivre)),1)) colunalivre(posicao)]);
                    if auxiliarCusto == false
                        auxiliarCore(linhalivre(find(linhalivre==(min(linhalivre)),1)):linhalivre(find(linhalivre==(min(linhalivre)),1))+auxiliarArea(1,result(j))-1,colunalivre(posicao):colunalivre(posicao)+auxiliarArea(2,result(j))-1)=result(j);
                    else
                        posicao = find(colunalivre==auxiliarDiag(2),1);
                        auxiliarCusto = SobreposSA(auxiliarCore, auxiliarArea(:,result(j)),[linhalivre(find(linhalivre==(min(linhalivre)),1)) colunalivre(posicao)]);
                        if auxiliarCusto == false
                            auxiliarCore(linhalivre(find(linhalivre==(min(linhalivre)),1)):linhalivre(find(linhalivre==(min(linhalivre)),1))+auxiliarArea(1,result(j))-1,colunalivre(posicao):colunalivre(posicao)+auxiliarArea(2,result(j))-1)=result(j);
                        end
                    end
                end
            end
        end
     end
   
end

    if ~isempty(find(result == 0,1)) || auxiliarCusto > 0 || ~isempty(find(result > ((numel(result)-1)/2)+1,1))
        [linha, coluna] = size(auxiliarCore);
        resultCusto = linha * coluna * 100;
    else
        resultCusto = CalcPerimetro(auxiliarCore);
    end
save('auxiliarCore_Salva.mat', 'auxiliarCore');
end

