function [candidateTextRegions locs] = textcandidate( img )

    subplot(2,2,1);
    imshow(img);
    
    [IxyMag IxyTheQuant] = cannyp(img);
    
    % Dilate horizontal edges
    horiz = zeros(size(IxyMag));
    horiz(IxyTheQuant == 2 & IxyMag == 1) = 1;
    horizdil = imdilate(horiz,  strel('rectangle',[10 5]));
    subplot(2,2,2); imagesc(horizdil);

    % Dilate Vertical Edges
    vert = zeros(size(IxyMag));
    vert(IxyTheQuant == 0 & IxyMag == 1) = 1;
    vertdil = imdilate(vert, strel('rectangle',[3 15]));
    subplot(2,2,3); imagesc(vertdil);
    
    % Show the composite image
    colormap(gray)
    jointMap = logical(horizdil.*vertdil);
    jointMap = imclose(jointMap, strel('rectangle',[2 15]));
    subplot(2,2,4); imshow(jointMap)

    % Crop candidate text regions and store them
    candidateTextRegions = img.*uint8(jointMap);

    % Find components with 8-way connectived
    BW = bwconncomp(candidateTextRegions, 8);
    STATS = regionprops(BW, 'all');

    subImages = cell(BW.NumObjects,1);
    locs = zeros(BW.NumObjects,2);

    % Extract The Connected Components
    for i=1:BW.NumObjects
        BBox         = round(STATS(i).BoundingBox);
        subImages{i} = imcrop(img, BBox);
        locs(i,:)    = BBox(1:2);
    end
    
    candidateTextRegions = subImages;
end