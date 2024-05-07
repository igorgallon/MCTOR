function [OutPop] = PopACA(NumPop,NocX, NocY, S, T, W)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
auxNum = NocX * NocY;

            % Gera clusters
for j = 1: max([S,T])
    indices = [find(S == j) find(T == j)];
    clusters(j) = sum(W(indices));
end
            % Ordena clusters
[~, indicesOrdenados] = sort(clusters, 'descend');

            % Gera os indices
[LN,CL]=ind2sub([NocX NocY],1:NocX*NocY);
Pos_Tab=[LN' CL'];
            % Cria uma tabela de distancias
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');
            
for i=1 : NumPop
    auxPos = randi(auxNum);
    %auxPos = 16;       %Teste pior caso
    individuo = zeros(1, auxNum);
    newAdj = [];
    try
        for k = 1 : numel(S) + numel(T)
            if k == 1
                individuo(auxPos) = indicesOrdenados(k);
                indicesS = [find(S == individuo(auxPos))];
                indicesT = [find(T == individuo(auxPos))];
                adjacentes = [T(indicesS) S(indicesT)];
                individuo = Distcluster(indicesOrdenados(k), individuo, adjacentes, Dist_Tab, auxPos);
                auxCluster = individuo(individuo ~= individuo(auxPos));
                auxCluster = auxCluster(auxCluster ~= 0);
            else
                auxPosCluster = find(ismember(indicesOrdenados, auxCluster));
                auxPos = find(ismember(individuo,indicesOrdenados(auxPosCluster(1)))==1);
                %iParei aqui falta distribuir as tarefasdaqui
                indicesS = [find(S == individuo(auxPos))];
                indicesT = [find(T == individuo(auxPos))];
                adjacentes = unique([T(indicesS) S(indicesT)]);
                auxIndividuo = individuo;
                individuo = Distcluster(indicesOrdenados, individuo, adjacentes, Dist_Tab, auxPos);
                auxCluster = auxCluster(auxCluster ~= auxCluster(find(auxCluster == individuo(auxPos))));
                newAdj = [newAdj setdiff(individuo, auxIndividuo)];
                if isempty(auxCluster)
                    auxCluster = newAdj;
                end
                
            end
        end
    catch
        disp('Error');
    end
    OutPop(i,:) = individuo;
end
end
function outindiv = Distcluster(Task, Indiv, Adj, Dist, auxPos)

%for m = 1 : numel(Adj)
     indFree = 1;
     indAdj = find(Dist(auxPos, :)==indFree);
     while numel(Adj) > 0
         
         %indLivre = find(Dist(auxPos, :)==indFree);
         indNew = randi(numel(indAdj));
         Adj = Adj(~ismember(Adj, Indiv));
         if isempty(Adj)
             break
         end
         indNewAdj = randi(numel(Adj));
         if any(Indiv == Adj(indNewAdj));
             Adj = setdiff(Adj,Adj(indNewAdj));
             if isempty(Adj)
                 break
             end
         else
             if Indiv(indAdj(indNew)) == 0 && ~isempty(Adj)
             Indiv(indAdj(indNew)) = Adj(indNewAdj);
             Adj = setdiff(Adj,Adj(indNewAdj));
             indAdj = setdiff(indAdj, indAdj(indNew));
             if isempty(indAdj) && ~isempty(Adj)
                 indFree = indFree + 1;
                 indAdj = find(Dist(auxPos, :)==indFree);
             end
             elseif Indiv(indAdj(indNew)) > 0 && ~isempty(Adj)
                 indAdj = setdiff(indAdj, indAdj(indNew));
                 if isempty(indAdj) && ~isempty(Adj)
                 indFree = indFree + 1;
                 indAdj = find(Dist(auxPos, :)==indFree);
             end
             end
         end
         
     end
%end

outindiv = Indiv;
end

