function [outCusto] = CustoACA(Pop, NocX, NocY, S, T, W)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
auxNum = NocX * NocY;

            % Gera os indices
[LN,CL]=ind2sub([NocX NocY],1:NocX*NocY);
Pos_Tab=[LN' CL'];
            % Cria uma tabela de distancias
Dist_Tab=pdist2(Pos_Tab,Pos_Tab,'cityblock');

for k = 1 : size(Pop,1)
    individuo = Pop(k,:);
            % Gera clusters
    for j = 1: numel(individuo)
        task = individuo(j);
        indices = [find(S == task) find(T == task)];
        auxCusto = [];
        for r = 1 : numel(indices)
            auxCusto(r) = W(indices(r)) * Dist_Tab(find(individuo == S(indices(r))), find(individuo == T(indices(r))));
        end
        clusters(j) = sum(auxCusto(1:end));
    end
    outCusto(k) = sum(clusters(1:end));

end


end

