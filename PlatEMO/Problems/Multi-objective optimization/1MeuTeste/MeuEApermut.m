function Offspring = MeuEApermut(Global,Parent)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %Parent    = Parent([1:end,1:ceil(end/2)*2-end]);
    ParentDec = Parent;%Parent.decs;
    [N,D]     = size(ParentDec);
    %D=12;
    %% Order crossover
    OffspringDec = ParentDec;
    k = randi(D-1,1,N);
    
    for i = 1 : N/2

        Diff_1   = setdiff(ParentDec(i+N/2,:),ParentDec(i,1:k(i)),'stable');
        Diff_1(1, (length(Diff_1)+1):(D-k(i))) = 0;
        Diff_2   = setdiff(ParentDec(i,:),ParentDec(i+N/2,1:k(i)),'stable');
        Diff_2(1, (length(Diff_2)+1):(D-k(i))) = 0;

        OffspringDec(i,k(i)+1:end) = Diff_1(1,1:D-k(i));
        OffspringDec(i+N/2,k(i)+1:end) = Diff_2(1,1:D-k(i));
        
    end
       %% Slight mutation
    
    
    k = randi(D,1,N);
    s = randi(D,1,N);
    for i = 1 : N
        if s(i) < k(i)
            OffspringDec(i,:) = OffspringDec(i,[1:s(i)-1,k(i),s(i):k(i)-1,k(i)+1:end]);
        elseif s(i) > k(i)
            OffspringDec(i,:) = OffspringDec(i,[1:k(i)-1,k(i)+1:s(i)-1,k(i),s(i):end]);
        end
    end
    
    Offspring = OffspringDec; %INDIVIDUAL(OffspringDec);
end

