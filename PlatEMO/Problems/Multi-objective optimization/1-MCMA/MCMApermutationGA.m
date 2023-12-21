function Offspring = MCMApermutationGA(Parent1,Parent2,proC,mutationRate)
% Genetic operators for permutation variables
% Added by Manoel Aranda de Almeida 25/05/2023
% to include GA operator version for Many-Core
    
    %% Order crossover
    
    Offspring = [Parent1;Parent2];
    [N, D] = size(Offspring);
    ParentDec = Offspring;
    k = randi(D-1,1,N);
    
    for init = 1 : N/2
        Diff_1   = setdiff(ParentDec(init+N/2,:),ParentDec(init,1:k(init)),'stable');
        Diff_2   = setdiff(ParentDec(init,:),ParentDec(init+N/2,1:k(init)),'stable');

        Offspring(init,:) = [ParentDec(init,1:k(init)) ParentDec(init+N/2,k(init)+1:end)];
        Offspring(init+N/2,:) = [ParentDec(init+N/2,1:k(init)) ParentDec(init,k(init)+1:end)];
    end
    
    %% Permutation
    
    % Define the number of chromosomes to mutate
    numMutations = ceil(N*mutationRate);
    % Retrieve the random indexes
    popIdx = randperm(N, numMutations);

    for i=1:numMutations
        % Select the chromosome
        p = Offspring(popIdx(i),:);
        % Find a random interval to mutate
        indexes = randperm(D,2);
        init = min(indexes);
        finish = max(indexes);
        % Permutate the cells in the interval
        mutated = flip(p(init:finish));
        % Save in the current chromosome
        Offspring(popIdx(i),:) = [p(1:(init-1)) mutated p((finish+1):D)];
    end
end

