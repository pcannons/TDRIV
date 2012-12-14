im = feature_struct.images{42};

[subimages locs] = textcandidate(im);

[subimages locs] = pruneCandidates(subimages, locs);
close all
imshow(im);
hold on;

subpics = {};
for i = 1:numel(subimages)
    rects = extractLines(subimages{i}, locs(i,:));
    %close all;
    %subpics = [subpics; getRegions(im, rects)];  
end

%subpics(cellfun(@isempty,subpics)) = [];