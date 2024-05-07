S1 = [1  2  1  3  4  4  2];
T1 = [2  3  4  5  6  7  8];
W1 = [21 42 31 45 49 45 4];

numNoC  = [3, 3]; %tamanho do Noc
numTarefas = 8;

tic;
for k=1:1000
    controlEncode = 5 * ones(1, numTarefas);
    controlLower = ones(1,numTarefas);
    controlUpper = numNoC(1,1) * numNoC(1,2) * controlLower;
    params = numNoC(1,1) * numNoC(1,2);

    f1 = @(x)MCCustoSA(numNoC, S1, T1, W1, numTarefas, x);
    
    [s1, s2, s3] = platemo('objFcn',f1,'algorithm',@SAPermut,'encoding',controlEncode,'lower',1,'upper',16,'parameter',params);
    TesteMCSA{k} = [s1, s2];
end

save('SalvoTesteMCSA100.mat','TesteMCSA');
disp('Executado!');
disp(['Tempo decorrido: ', num2str(toc), ' segundos']);