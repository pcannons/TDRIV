function segImage = graykmeans(img, k)
    iSize = size(img);

    % Initialize
    means = rand(k, 1);
    means(:, 1) = round(means(:, 1).*255);

    minChange = 0;

    % Made the image into a column for some optimizations
    imgc = double(reshape(img, iSize(1)*iSize(2),1));
    change = realmax.*ones(3,1);
    newMeans = zeros(size(means));
    %iteration = 0;

    while (any(arrayfun(@gt, change, minChange.*ones(length(change),1))))     
        % Report Status
        %iteration = iteration + 1;
        %fprintf('Iteration: %i\n', iteration);
        %fprintf(' Change: %f\n', change);

        bins  = ones(iSize(1)*iSize(2), 1);
        dists = realmax.*ones(iSize(1)*iSize(2), 1);
        for i = 1:k
            Y = means(i, :);
            newDist = bsxfun(@plus,dot(imgc,imgc,2),dot(Y,Y,2))-2*(imgc*Y');
            updateLocs = (dists >= newDist);
            bins(updateLocs)  = i;
            dists(updateLocs) = newDist(updateLocs);
        end

        % Move the mean to the centroid of the cluster
        for i = 1:k 
            points = imgc(bins == i, :);
            newMeans(i, :) = round(mean(points,1));
        end
        newMeans(isnan(newMeans)) = 255.*rand();
        change = sqrt(sum((newMeans-means).^2,2));
        means = newMeans;

    end

    % Reconstruct the image using the quantized color
    segImage = zeros(iSize(1)*iSize(2), 1, 'uint8');
    for i = 1:k
        segImage(bins == i, i) = 1;
    end
    segImage = reshape(segImage, [iSize k]);
    %imshow(segImage);
end