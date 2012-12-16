im = feature_struct.images{2};

% Scale down very large images
[m, ~] = size(im);
if (m > 400)
    im = imresize(im, 400 / m);
end
[m n] = size(im);
if (n > 400)
    im = imresize(im, 400 / n);
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