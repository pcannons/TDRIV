function rects = extractLines(subpic, loc, showRects)
    % Convert to black and white
    %subbw = im2bw(subpic,.5);
    %close all; imshow(subpic);
    spSize = size(subpic);

    % Project to Y axis
    %horizproj = sum(subbw,2);
    
    [subedge, ~] = cannyp(subpic, 0.9);
    horizproj = sum(subedge, 2);

    %horizproj = smooth(horizproj,length(horizproj)/2);
    
    if (length(horizproj) < 8)
        rects = [];
        return;
    end
    
    %horizproj = smooth(horizproj,3);
    
    % This looks for zeros or 'near-zeros'
    %thresh = 1.618*std(horizproj);
    thresh = (mean(horizproj) + min(horizproj))/1.6;
    horizProjMinima = find(horizproj <= thresh);

    %[~, lineBreaks] = findpeaks(abs(diff(horizproj)), 'MINPEAKDISTANCE', 7);
    
    % This finds lines that don't differ by (7) * THIS IS FROM MATLAB FILE
    % EXCHANGE *
    lineBreaks = mat2cell(horizProjMinima',1,diff([0,find(diff(horizProjMinima') >= 5),length(horizProjMinima)]));

    % Remove consequtive lines with median
    lineBreaks = round(cellfun(@median, lineBreaks));
    
    if (lineBreaks(1) > 7)
        if (horizproj(1) >= thresh)
            lineBreaks = [1 lineBreaks];
        end
    end
    
    if ((length(horizproj) - lineBreaks(end)) > 7)
        if (horizproj(end) >= thresh)
            lineBreaks = [lineBreaks length(horizproj)];
        end
    end
    
%     breaks = [];
%     for i = 1:numel(lineBreaks)
%         if (length(lineBreaks{i}) < 2)
%             rects = [];
%             return;
%         end
%         set = lineBreaks{i};
%         newBreaks = [set(1) set(end)];
%         newBreaks(1) = newBreaks(1)-abs(newBreaks(1)-newBreaks(2));
%         newBreaks(1) = round(newBreaks(1));
%         newBreaks(2) = newBreaks(2)+.25*abs(newBreaks(1)-newBreaks(2));
%         newBreaks(2) = round(newBreaks(2));
%         if (newBreaks(1) < 1)
%             newBreaks(1) = 1;
%         end
%         if (newBreaks(2) > spSize(1))
%             newBreaks(2) = spSize(1);
%         end
%         breaks(end+1:end+2) = newBreaks;
%     end
%     lineBreaks = breaks;

%     if (numel(lineBreaks) == 0)
%         rects = [loc(1), loc(2), spSize(2), spSize(1)];
%         rectangle('Position', [loc(1), loc(2), spSize(2), spSize(1) ], ...
%         'LineWidth', 1.5, 'edgecolor', 'red');
%         return;
%     elseif (numel(lineBreaks) == 1)
%         lineBreaks = [0 lineBreaks lineBreaks spSize(2)];
%         
%     end

    breaks = lineBreaks;
    lineBreaks =  zeros((numel(breaks) - 1),2);
    for i = 1:numel(breaks)-1
        lineBreaks(i,1) = breaks(i)-abs(lineBreaks(i,1)-lineBreaks(i,2));
        if (lineBreaks(i,1) < 1)
            lineBreaks(i,1) = 1;
        end
        lineBreaks(i,2) = breaks(i+1);
    end
    lineBreaks = reshape(lineBreaks, (numel(lineBreaks)/2), 2);

    zSize = size(lineBreaks);
    rects = zeros(zSize(1), 4);
    for i = 1:zSize(1)
        if (lineBreaks(i,2) - lineBreaks(i,1) < 8) 
            continue;
        end
        rects(i,:) = [loc(1), loc(2)+ lineBreaks(i, 1), spSize(2), lineBreaks(i,2) - lineBreaks(i,1)];
        if (strcmp(showRects,'true'))
            rectangle('Position', [loc(1), loc(2)+ lineBreaks(i, 1), spSize(2), lineBreaks(i,2) - lineBreaks(i,1)], ...
            'LineWidth', 1.5, 'edgecolor', 'red');
        end
    end


end