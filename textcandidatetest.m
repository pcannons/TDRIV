im = feature_struct.images{63};

% Scale down very large images
[m, ~] = size(im);
if (m > 720)
    im = imresize(im, 720 / m);
end
[m n] = size(im);
if (n > 720)
    im = imresize(im, 720 / n);
end

[subimages locs] = textcandidate(im);
%%
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