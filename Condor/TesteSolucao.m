% Noc com tarefas
Line = 5;
Column = 5;
nTask = 16;
NumSol = 13;
auxSolu = SoluComparaVOPD5x5{NumSol, 1,:};
Solu = auxSolu(1,:);
SoluOb = SoluComparaVOPD5x5{NumSol, 2,:};

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

TotalNoc = PosiNoc';