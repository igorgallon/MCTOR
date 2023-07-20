function varargout = MML(Operation,Global,input)
% <problem> <Morphology>
% Multi-objective Linear MM
% nOp --- 5 --- Number of Operators
% Im_N --- 1 --- Number of Image
% operator  --- EAbinaryLin

%--------------------------------------------------------------------------
% Copyright (c) 2016-2017 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB Platform
% for Evolutionary Multi-Objective Optimization [Educational Forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------


[nOp Im_N] = Global.ParameterSet(100,100);

    switch Operation
        case 'init'
            Global.M        = 2;
            Global.M        = 2;
            Global.D        = 10;
            Global.operator = @EAbinaryLin;
                       
            
            n            = Global.D;        
            
            PopDec    = randi(nOp,input,n);
            
            
            varargout = {PopDec};
            
        case 'value'
            
            % Functions Definitions
            % F1: Functions used to calculate costs
                F1={'imdilate(im_in,ones(3,3))','imerode(im_in,ones(3,3))','imdilate(im_in,ones(5,5))','imerode(im_in,ones(5,5))','Nop(im_in)'};

            % Complexity Values
                F2={2,3,4,5,1};
                
            % Input image
                im_in=imread('im_in_1.bmp');

            % Output image
                im_out=imread('im_out_1.bmp'); 
                
            PopDec = input;
            
            PopObj=Calc_cost(PopDec,im_in,im_out,F1,F2,Global.M,Global.N,Global.D);
            
            PopCon = [];
            
            varargout = {input,PopObj,PopCon};
        case 'PF'
            
            RefPoint  = [0,0];
            varargout = {RefPoint};
            
    end
end





