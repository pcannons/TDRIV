function pred = svmPredict(model, X)
%	Description: Returns a vector of predictions using a trained SVM model
%   
%   Parameters: X - mxn matrix where there each example is a row 
%   
%               Y - column matrix containing 1 for positive examples 
%               and 0 for negative examples.  
%               model - SVM model returned from svmTrain
%
%   Return:     pred - m x 1 column of predictions of {0, 1} values

% Check if getting column vector, if so, then only
% need to do prediction for a single example
if (size(X, 2) == 1)
    % Examples should be in rows
    X = X';
end

% Dataset 
m = size(X, 1);
p = zeros(m, 1);
pred = zeros(m, 1);

% Vectorized RBF Kernel
% This is equivalent to computing the kernel on every pair of examples
X1 = sum(X.^2, 2);
X2 = sum(model.X.^2, 2)';
K = bsxfun(@plus, X1, bsxfun(@plus, X2, - 2 * X * model.X'));
K = model.kernelFunction(1, 0) .^ K;
K = bsxfun(@times, model.y', K);
K = bsxfun(@times, model.alphas', K);
p = sum(K, 2);

% Convert predictions into 0 / 1
pred(p >= 0) =  1;
pred(p <  0) =  0;

end

