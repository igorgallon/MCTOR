%------------------------------- Reference --------------------------------
% Created by Manoel Aranda de Almeida 25/05/2023
% to optimize Many-Core
%--------------------------------------------------------------------------
% numPop - tamanho da população
% numTasks - quantidade de tarefas
% numProc - tamanho do cromossomo igual numero de roteadores
% No Individuo cada posição é uma tarefa o valor de cada posição do
% indivíduo é um roteador e precisa usar 
function popOut = MCMAPopInitV2(numPop, numTasks, nRows, nColumns, selectAlgorithm)

    numProc = nRows*nColumns;
    
    if selectAlgorithm == 0
        popOut = randi(numProc, numPop,  numTasks);
    else
        % Used to store the processors id arranged by the selected Engineered
        % Mapping algorithm
        coresMatrix = reshape(1:numProc, nColumns, nRows).';
        % Used to store the tasks id according to the processors arrangement
        mappedPop = zeros(numPop, numTasks);
        % Used to store the initial sequence of tasks ids
        tasksIds = zeros(numPop, numTasks);
        
        % Populate the initial sequence of tasks by random permutation from 1 to
        % numTasks        
        for i = 1:numPop
            tasksIds(i,:) = randperm(numTasks);
        end
        
        % Select the Engineered Mapping algorithm
        switch selectAlgorithm
            case 1
                coresId = utils.horizontalRaster(nRows, nColumns, coresMatrix);
            case 2
                coresId = utils.horizontalSnake(nRows, nColumns, coresMatrix);
            case 3
                coresId = utils.diagonalRaster(nRows, nColumns, coresMatrix);
            case 4
                coresId = utils.diagonalSnake(nRows, nColumns, coresMatrix);
        end
        
        % Apply the Engineered Mapping in the tasks arrangement
        for i=1:numPop
            k = 1;
            for j=1:numTasks
                ind = mod(k-1,numProc)+1;
                mappedPop(i,tasksIds(i,j)) = coresId(ind);
                k = k+1;
            end
        end
        
        % Generate half of population by random permutation only
        % randomPop = randi(numProc, numPop,  numTasks);
        
        % The initial population is composed of random placement and engineered
        % mapping
        popOut = mappedPop;
    end
end