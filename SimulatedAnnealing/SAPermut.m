classdef SAPermut < ALGORITHM
% <single> <real/integer> <large/none> <constrained/none>
% Simulated annealing

%------------------------------- Reference --------------------------------
% D. Bertsimas and J. Tsitsiklis, Simulated annealing, Statistical Science,
% 1993, 8(1): 10-15.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2023 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Generate random solution
            X     = Problem.Initialization(1);
            T     = 0.15;
            sigma = 0.1*(Problem.upper-Problem.lower);
            
            %% Optimization
            while Algorithm.NotTerminated(X)
                for i = 1 : Problem.N
                    mu       = rand(1,Problem.D) < 0.5;
                    Ydec     = X.dec;
                    Ydec(mu) = Ydec(mu) + sigma(mu).*randn(1,sum(mu));
                    Ydec = round(Ydec);
                    
                    %Elimina zero
                    if ~isempty(find(Ydec <= 0,1))
                        Ydec(Ydec <= 0) = X.dec(find(Ydec <= 0));
                    end
                    %Elimina valor inválido
                    if ~isempty(find(Ydec > Algorithm.parameter, 1))
                        Ydec(Ydec > Algorithm.parameter) = X.dec(find(Ydec > Algorithm.parameter));
                    end
                    
                    if ~isempty(setdiff(X.dec(mu), Ydec(mu)))
                        auxDif = setdiff(X.dec(mu), Ydec(mu));
                        for j=1:numel(auxDif)
                            auxPosY = find(X.dec == auxDif(j));
                            auxPosX = find(X.dec == Ydec(auxPosY));
                            Ydec(1, setdiff(auxPosX, auxPosY)) = X.dec(1, auxPosY);
                        end
                    end
                    
                    Y        = Problem.Evaluation(Ydec);

                    if rand < exp(-(FitnessSingle(Y)-FitnessSingle(X))/(abs(FitnessSingle(X))+1e-6)/T)
                        X = Y;
                    end
                    T     = T*0.99;
                    sigma = sigma*0.99;
                end
            end
        end
    end
end