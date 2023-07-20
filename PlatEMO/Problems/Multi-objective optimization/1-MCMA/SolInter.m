%Script para encontrar uma solução intermediária

Resultados = Obj;

for i=1:length(Resultados)
    Res=(Resultados(i,1)/1000);
    Res2 =Resultados(i,2);
    Distancias(i) = sqrt((Resultados(i,1)/1000)^2+(Resultados(i,2))^2);
end

    Menor = find(Distancias==min(Distancias));