function MinhaPopOut = MinhaPop(Npop, Tarefas, Tamcrom)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
% Npop - tamanho da população
% Tarefas - quantidade de tarefas
% Tamcrom - tamanho do cromossomo igual numero de roteadores

%v = (1:1:Tarefas);
%Pop = perms(v);
%[m, ~] = size(Pop);
%idx = randperm(m, Npop);

B = (1:1:Tarefas);
B(Tarefas+1:Tamcrom) = 0;
C = zeros(Npop,Tamcrom);
for i=1:Npop
    C(i,:)=randperm(Tamcrom);
end
%C = repmat((randperm(Tamcrom)), Npop, 1);

MinhaPopOut = B(C);


end

