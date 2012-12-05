function [prunedsi prunedlocs] = pruneCandidates(subImages, locs)
%   Remove subimages based on the heurstics in the baseline detection
%   research paper
%
%   Includes: Minimum Pixel Count, Aspect Ratio, Line Height etc

MIN_SIZE = 800;
MIN_LINE_HEIGHT = 1.2;
MIN_WIDTH = 8;

prunedsi = subImages;
prunedlocs = locs;
toBeRemoved = [];
for i = 1:numel(subImages)
    siSize = size(subImages{i});
    if (siSize(1)*siSize(2) < MIN_SIZE) % Minimum Size
        toBeRemoved(end + 1) = i;
    end
    
    if (siSize(2)/siSize(1) < MIN_LINE_HEIGHT) % Too skinny
        toBeRemoved(end + 1) = i;
    end
    
    if (siSize(1) < MIN_WIDTH) % Too short
        toBeRemoved(end + 1) = i;
    end
    
end

prunedsi(toBeRemoved) = [];
prunedlocs(toBeRemoved,:) = [];

end