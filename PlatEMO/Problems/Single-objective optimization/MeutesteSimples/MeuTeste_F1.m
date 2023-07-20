classdef MeuTeste_F1 < PROBLEM
% <single><real><expensive/none>
% Sphere function
%------------------------ Reference -----------------------
% X. Yao, Y. Liu, and G. Lin, Evolutionary programming made 
% faster, IEEE Transactions on Evolutionary Computation,
% 1999, 3(2): 82-102.
%----------------------------------------------------------
methods
 function Setting(obj)
 obj.M = 1;
 if isempty(obj.D); obj.D = 30; end
 obj.lower = zeros(1,obj.D) - 100;
 obj.upper = zeros(1,obj.D) + 100;
 obj.encoding = ones(1,obj.D);
 end
 function PopObj = CalObj(obj,PopDec)
 PopObj = sum(PopDec.^2,2);
 end
end
end