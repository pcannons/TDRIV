function [C, sigma] = dataset3Params(X, y, Xval, yval)
%dataset3Params returns optimal (C, sigma) learning parameters to use for
%SVM with RBF kernel
%   [C, sigma] = dataset3Params(X, y, Xval, yval) returns optimal C and 
%   sigma based on cross-validation set.
%

    Cv = [0.01 0.03 0.1 0.3 1 3 10 30];
    Sv = Cv;

    bestC = 1;
    bestSigma = 0.3;
    bestError = 99999999;
    errorMat = zeros(length(Cv), length(Sv));

    for cIndx = 1:length(Cv)
        for sIndx = 1:length(Sv);
            C = Cv(cIndx);
            sigma = Sv(sIndx);
            model = svmTrain(X, y, C, @(x1, x2) gaussianKernel(x1, x2, sigma));
            pred = svmPredict(model,Xval);
            error = mean(double(pred ~= yval));
            errorMat(cIndx,sIndx) = error;
            if (error < bestError)
                bestC = C;
                bestSigma = sigma;
                bestError = error;
            end
        end
    end

    C = bestC;
    sigma = bestSigma;

end