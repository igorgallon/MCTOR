function LoadB = MCMA_Load_balance(A, nR, nC);
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumNoc = nR * nC;

for m=1:NumNoc
    %Procura os indices e converte
TarefaPorNoc(m) = sum(A(:) == m);
end
LoadB = std(A,1);
media = mean(TarefaPorNoc, 'all');
DistPorNoc = TarefaPorNoc - media;
Loadc = sqrt((sum(abs(DistPorNoc)))/NumNoc);
LoadB = sqrt((sum(abs(DistPorNoc)))/NumNoc);
end