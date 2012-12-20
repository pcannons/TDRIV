function [C, sigma] = dataset3Params(X, y, Xval, yval)
%	Description: using a cross validation set, computes optimal (C, sigma) 
%                learning parameters to use for SVM with RBF kernel
%   
%   Parameters: X - mxn matrix where there each example is a row 
%               y - column matrix containing 1 for positive examples 
%               and 0 for negative examples.  
%               Xval - same as X but used for cross validation set
%               yval - same as y but used for cross validation set
%
%   Return:     C - optimal C based on cross-validation set
%               sigma -optimal sigma based on cross-validation set

    % Values of C to try
    Cv = [0.01 0.03 0.1 0.3 1 3 10 30];
    Sv = Cv;

    bestC = 1;
    bestSigma = 0.3;
    bestError = 99999999;
    errorMat = zeros(length(Cv), length(Sv));

    for cIndx = 1:length(Cv)
        errorMatSlice = zeros(1, length(Sv));
        C = Cv(cIndx);
        parfor sIndx = 1:length(Sv);
            sigma = Sv(sIndx);
            model = svmTrain(X, y, C, @(x1, x2) gaussianKernel(x1, x2, sigma));
            pred = svmPredict(model,Xval);
            error = mean(double(pred ~= yval));
            errorMatSlice(sIndx) = error;
        end
        errorMat(cIndx,:) = errorMatSlice;
    end
    
    [bestC bestSigma] = ind2sub(size(errorMat), find(errorMat == min(min(errorMat)),1));

    C = bestC;
    sigma = bestSigma;

end