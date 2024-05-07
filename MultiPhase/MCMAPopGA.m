
function MinhaPopOut = MCMAPopGA(Npop, Tarefas, NumNoc)
%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
% Npop - tamanho da população
% Tarefas - quantidade de tarefas
% NumNoc - tamanho do cromossomo igual numero de roteadores
% No Individuo cada posição é uma tarefa o valor de cada posição do
% indivíduo é um roteador e precisa usar 


for i = 1 : Npop
MinhaPopOut(i,:) = randperm(NumNoc,  Tarefas);
end

end

