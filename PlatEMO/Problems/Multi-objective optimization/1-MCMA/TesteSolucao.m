% Noc com tarefas
Line = 4;
Column = 4;
nTask = 26;
NumSol = 49;
Solu = Dec(NumSol,:);
SoluOb = Obj(NumSol,:);

NumNoc = Line*Column;
PosiNoc = zeros(NumNoc, nTask);
%Tasks = 1:NumNoc;

for s=1:NumNoc
     if ismember(s, Solu)
         Var1 = find(Solu == s);
         PosiNoc(s,1:length(Var1)) = Var1;
     end
end

Tarefas=[1:NumNoc];
Validar = 0;
for i=1:length(Dec)
    Ind = Dec(i,:);
    Teste = ismember(Ind, Tarefas);
    if ismember(0, Teste)
        Validar = Validar + 1;
    end
end

TotalNoc = PosiNoc'