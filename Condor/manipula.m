
for i = 1 : 100
    ACAcusto = result4x4{i,2};
    ACApop = result4x4{i,1};
    menor = find(min(ACAcusto == ACAcusto), 1);
    resACAVOPD4x4{i} = {ACApop(menor,:) ACAcusto(menor)};
end