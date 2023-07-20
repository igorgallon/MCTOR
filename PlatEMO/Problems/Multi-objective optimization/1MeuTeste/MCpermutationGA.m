function Offspring = MCpermutationGA(Parent1,Parent2,proC)
% Genetic operators for permutation variables
% Added by Manoel Aranda de Almeida 25/05/2023
% to include GA operator version for Many-Core

    %% Order crossover
    
    Offspring = [Parent1;Parent2];
    [N, D] = size(Offspring);
    ParentDec = Offspring;
    k = randi(D-1,1,N);
    
    for i = 1 : N/2

        Diff_1   = setdiff(ParentDec(i+N/2,:),ParentDec(i,1:k(i)),'stable');
        Diff_1(1, (length(Diff_1)+1):(D-k(i))) = 0;
        Diff_2   = setdiff(ParentDec(i,:),ParentDec(i+N/2,1:k(i)),'stable');
        Diff_2(1, (length(Diff_2)+1):(D-k(i))) = 0;

        Offspring(i,k(i)+1:end) = Diff_1(1,1:D-k(i));
        Offspring(i+N/2,k(i)+1:end) = Diff_2(1,1:D-k(i));
        
    end
    
    %% Slight mutation
    % Added by Manoel Aranda de Almeida 25/05/2023
    % to include GA operator version for Many-Core

    k = randi(D,1,N);
    s = randi(D,1,N);
    for i = 1 : N
        if s(i) < k(i)
            Offspring(i,:) = Offspring(i,[1:s(i)-1,k(i),s(i):k(i)-1,k(i)+1:end]);
        elseif s(i) > k(i)
            Offspring(i,:) = Offspring(i,[1:k(i)-1,k(i)+1:s(i)-1,k(i),s(i):end]);
        end
    end
end

