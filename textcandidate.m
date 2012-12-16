
function [candidateTextRegions locs] = textcandidate( img )

    %%
    iSize = size(img);
    subplot(2,2,1);
    imshow(img);
    
    %%

    % Make some kernels
    gauss = fspecial('gaussian', 5, 1.5);
    deriveX            = [-1  0  1; -1 0 1; -1 0 1];
    deriveY            = [-1 -1 -1;  0 0 0;  1 1 1];
    deriveGaussKernelX = conv2(gauss, deriveX, 'same');
    deriveGaussKernelY = conv2(gauss, deriveY, 'same');

    
    %%

    %
    % Our own implementation of Canny
    %
    % Gradient Calc
    Ixx = conv2(double(img), deriveGaussKernelX, 'same');
    Iyy = conv2(double(img), deriveGaussKernelY, 'same');

    % Gradient Magnitude and Angle
    IxyMag = arrayfun(@norm,  Ixx, Iyy);
    IxyThe = arrayfun(@atan2, Iyy, Ixx);

    % Clear unspecified values
    IxyMag(isnan(IxyMag)) = 0;
    
    % Normalize for thresholds
    IxyMag = IxyMag./(max(IxyMag(:)));
    
    % AUTOMATIC THRESHOLD SELECTION FROM MATLAB'S EDGE FUNCTION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    counts=imhist(IxyMag, 64);
    HIGHTHRESH = find(cumsum(counts) > 0.8*iSize(1)*iSize(2),...
    1,'first') / 64;
    LOWTHRESH = 0.3*HIGHTHRESH;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Quantize angle to 45degs
    IxyTheQuant = (IxyThe + pi)*180/pi;
    IxyTheQuant = mod(round(IxyTheQuant/45),4)*1;
    
    % Non-Maximum Suppressions
    for i = 5:iSize(1)-4
        for j = 5:iSize(2)-4
            if (IxyTheQuant(i, j) == 0) 
                if (IxyMag(i, j) < IxyMag(i, j + 1) || IxyMag(i, j) < IxyMag(i, j - 1))
                    IxyMag(i, j) = 0;
                end
            elseif  (IxyTheQuant(i, j) == 1) 
                if (IxyMag(i, j) < IxyMag(i - 1, j + 1) || IxyMag(i, j) < IxyMag(i + 1, j + 1))
                    IxyMag(i, j) = 0;
                end
            elseif  (IxyTheQuant(i, j) == 2) 
                if (IxyMag(i, j) < IxyMag(i - 1, j) || IxyMag(i, j) < IxyMag(i + 1, j ))
                    IxyMag(i, j) = 0;
                end
            elseif  (IxyTheQuant(i, j) == 3)
                if (IxyMag(i, j) < IxyMag(i - 1, j - 1) || IxyMag(i, j) < IxyMag(i + 1, j + 1))
                    IxyMag(i, j) = 0;
                end
            end
        end
    end
    
    % Hysterisis Thresholding (Uses Matlab's Connected Component Tools)
    metLowThreshold = IxyMag > LOWTHRESH;
    [highThreshX highThreshY] = find(IxyMag > HIGHTHRESH);
    IxyMag = bwselect(metLowThreshold, highThreshY, highThreshX, 8);
    
    %imshow(IxyMag);
    
    % Remove false edges from picture border
    IxyMag(1:5,:) = 0;
    IxyMag(end-5:end,:) = 0;
    IxyMag(:,1:5) = 0;
    IxyMag(:,end-5:end) = 0;
    
    
    %%
    % Dilate horizontal edges
    horiz = zeros(size(IxyMag));
    horiz(IxyTheQuant == 2 & IxyMag == 1) = 1;

    %imagesc(horiz);
    horizdil = imdilate(horiz,  strel('rectangle',[16 8]));
    subplot(2,2,2); imagesc(horizdil);
    
    %%
    % Dilate Vertical Edges
    vert = zeros(size(IxyMag));
    vert(IxyTheQuant == 0 & IxyMag == 1) = 1;

    vertdil = imdilate(vert, strel('rectangle',[3 15]));
    subplot(2,2,3); imagesc(vertdil);

    %%
    % Show the composite image
    colormap(gray)
    subplot(2,2,4); imshow(logical(horizdil.*vertdil))

    %%
    % Crop candidate text regions and store them
    candidateTextRegions = img.*uint8(horizdil.*vertdil);

    BW = bwconncomp(candidateTextRegions, 8);
    STATS = regionprops(BW, 'all');

    subImages = cell(BW.NumObjects,1);
    locs = zeros(BW.NumObjects,2);

    for i=1:BW.NumObjects
        BBox = round(STATS(i).BoundingBox);
        subImages{i} = imcrop(img, BBox);
        locs(i,:)    = BBox(1:2);
        %imshow(cell2mat(subImages(i,1)));
    end
    
    candidateTextRegions = subImages;
end