function [GrafoComposto, GrafoComprimento] = UniGrafo(ParamGrafo)
% Tese de Doutorado de Manoel Aranda de Almeida 05/07/2023
% Função que faz a junçaõ de grafos para executar no Platemo

[L,W]= size(ParamGrafo);

 for i=1:W
    Grafo=ParamGrafo{i};
    
    Line(i,:)=Grafo{2};
    Column(i,:)=Grafo{3};

    Type(i)=Grafo{7};
    if i==1
            S=Grafo{4};
            T=Grafo{5};
            P=Grafo{6};
            Task=Grafo{1};
            GrafoComprimento(i) = Task;
    else
        S1=Grafo{4};
        T1=Grafo{5};
        P1=Grafo{6};
        
        S = cat(2, S, S1 + Task);
        T = cat(2, T, T1 + Task);
        P = cat(2, P, P1);
        Task = Task + Grafo{1};
        GrafoComprimento(i) = Task;
    end

end

GrafoComposto = {Task, Line(1), Column(1), S, T, P, Type(1)};
end

