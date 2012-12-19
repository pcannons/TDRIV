
im = feature_struct.images{10};

% Scale down very large images
[m, ~] = size(im);
if (m > 400)
    im = imresize(im, 400 / m);
end
[m n] = size(im);
if (n > 400)
    im = imresize(im, 400 / n);
end

%i1 = impyramid(im, 'reduce');

[subimages locs] = textcandidate(im, 'false');
[subimages locs] = pruneCandidates(subimages, locs);
imshow(im);
hold on;

for i = 1:numel(subimages)
    rects = extractLines(subimages{i}, locs(i,:), 'true');
    %close all;
    %subpics = [subpics; getRegions(im, rects)];  
end
