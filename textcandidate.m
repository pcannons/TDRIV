function [candidateTextRegions locs] = textcandidate( img )

    %%
    iSize = size(img);

    %%

    % Make some kernels
    gauss = fspecial('gaussian', 5, 1.4);
    deriveKernelX      = [-1  0  1; -2 0 2; -1 0 1];
    deriveKernelY      = [-1 -2 -1;  0 0 0;  1 2 1];

    %%

    %
    % This is canny without hysteris
    %

    % Gradient Calc
    Ix  = conv2(double(img), gauss, 'same');
    Ixx = conv2(Ix, deriveKernelX, 'same');
    Iy  = conv2(double(img), gauss, 'same');
    Iyy = conv2(Iy, deriveKernelY, 'same');

    % Gradient Magnitude and Angle
    IxyMag = arrayfun(@norm,  Ixx, Iyy);
    IxyThe = arrayfun(@atan2, Iyy, Ixx);

    % Quantize angle to 45degs
    IxyTheQuant = (IxyThe + pi)*180/pi;
    IxyTheQuant = mod(round(IxyTheQuant/45),4)*1;

    % Non Max Suppressions
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

    %%
    % Dilate horizontal edges
    horiz = zeros(size(IxyMag));
    horiz(IxyTheQuant == 2 & IxyMag > 35) = 1;
    horiz(isnan(horiz)) = 0;

    horizdil = imdilate(horiz, ones(30, 15));
    %imagesc(horizdil)
    %%

    % Dilate Vertical Edges
    vert = zeros(size(IxyMag));
    vert(IxyTheQuant == 0 & IxyMag > 50) = 1;
    vert(isnan(vert)) = 0;

    vertdil = imdilate(vert, ones(7,35));
    %imagesc(vertdil)

    %%
    % Show the composite image
    %colormap(gray)
    %imagesc(img.*uint8(horizdil.*vertdil))

    %%
    % Crop candidate text regions and store them
    candidateTextRegions = img.*uint8(horizdil.*vertdil);

    BW = bwconncomp(candidateTextRegions);
    STATS = regionprops(BW, 'all');

    subImages = cell(BW.NumObjects,1);
    locs = zeros(BW.NumObjects,2);

    for i=1:BW.NumObjects
        BBox = round(STATS(i).BoundingBox);
        subImages{i} = imcrop(candidateTextRegions, BBox);
        locs(i,:)    = BBox(1:2);
        %imshow(cell2mat(subImages(i,1)));
    end
    
    candidateTextRegions = subImages;
end