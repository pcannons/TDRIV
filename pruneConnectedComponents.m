function newRegion = pruneConnectedComponents(cc)
    newRegion = zeros(size(cc));
    cc = logical(cc);
    cc = bwconncomp(cc);
    regions = regionprops(cc);
    toBePruned = [];
    
    
    for i = 1:length(regions)

        bb      = regions(i).BoundingBox;
        regArea = regions(i).Area;

         % Aspect Ratio Pruning Heuristic
        if (bb(3)/bb(4) < 0.1 || bb(3)/bb(4) > 4.5)
            toBePruned(end + 1) = i;
            continue;
        end

        % Small area Pruning Heuristic
%         if (regArea < 10) 
%             toBePruned(end + 1) = i;
%             continue;
%         end
        
        % Fat latter Pruning Heuristic
        if (bb(3) > 2.1 * cc.ImageSize(2))
            toBePruned(end + 1) = i;
        end

    end
    
    cc.PixelIdxList(toBePruned) = [];
    cc.NumObjects = cc.NumObjects - length(toBePruned);
   
    for i = 1:cc.NumObjects
        newRegion(cc.PixelIdxList{i}) = 1;
    end

end