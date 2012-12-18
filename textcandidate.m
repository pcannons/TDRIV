function [candidateTextRegions locs] = textcandidate( img , showPics)

    if (strcmp(showPics, 'true'))
        subplot(2,2,1);
        imshow(img);
    end
    
    [IxyMag IxyTheQuant] = cannyp(img, 1.6);
    IxyMag(1:5,:)       = 0;
    IxyMag(end-5:end,:) = 0;
    IxyMag(:,1:5)       = 0;
    IxyMag(:,end-5:end) = 0;
    
    % Dilate horizontal edges
    horiz = zeros(size(IxyMag));
    horiz(IxyTheQuant == 2 & IxyMag == 1) = 1;
    horizdil = imdilate(horiz,  strel('rectangle',[10 5]));
    if (strcmp(showPics, 'true'))
        subplot(2,2,2); imagesc(horizdil);
    end
    
    % Dilate Vertical Edges
    vert = zeros(size(IxyMag));
    vert(IxyTheQuant == 0 & IxyMag == 1) = 1;
    vertdil = imdilate(vert, strel('rectangle',[3 15]));
    if (strcmp(showPics, 'true'))
        subplot(2,2,3); imagesc(vertdil);
    end
    
    % Show the composite image
    jointMap = logical(horizdil.*vertdil);
    jointMap = imclose(jointMap, strel('rectangle',[2 15]));
    %jointMap = imclose(jointMap, strel('rectangle',[6 6]));

    if (strcmp(showPics, 'true'))
        colormap(gray)
        subplot(2,2,4); imshow(jointMap)
    end

    % Crop candidate text regions and store them
    candidateTextRegions = uint8(jointMap);

    % Find components with 8-way connectived
    BW = bwconncomp(candidateTextRegions, 8);
    STATS = regionprops(BW, 'all');

    subImages = cell(BW.NumObjects,1);
    locs = zeros(BW.NumObjects,2);

    % Extract The Connected Components
    for i=1:BW.NumObjects
        BBox         = round(STATS(i).BoundingBox);
        BBox(2)      = BBox(2) - 3;
        BBox(4)      = BBox(4) + 6;
        if (BBox(1) < 1) 
            BBox(1)  = 1;
        end
        subImages{i} = imcrop(img, BBox);
        locs(i,:)    = BBox(1:2);
    end
    
    candidateTextRegions = subImages;
end