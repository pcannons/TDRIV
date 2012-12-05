function sim = gaussianKernel(x1, x2, sigma)
%RBFKERNEL returns a radial basis function kernel between x1 and x2
%   sim = gaussianKernel(x1, x2) returns a gaussian kernel between x1 and x2

    % Ensure x1 and x2 column vectors
    x1 = x1(:); 
    x2 = x2(:);

    % How similar x1 is to x2
    sim = exp(-sum((x1-x2).^2)/(2*sigma^2));

end
