function rects = extractLines(subpic, loc)
    % Convert to black and white
    subbw = im2bw(subpic,.5);
    %imshow(subbw);

    spSize = size(subpic);

    % Project to Y axis
    horizproj = sum(subbw,2);
    
    horizproj = smooth(horizproj,3);
    
    if (length(horizproj) < 11)
        rects = [];
        return;
    end
    
    %horizproj = smooth(horizproj,3);
    
    % This looks for zeros or 'near-zeros'
    %horizProjMinima = find(abs(diff(horizproj)) >= 1.5*std(abs(diff(horizproj))));

    [~, lineBreaks] = findpeaks(abs(diff(horizproj)), 'MINPEAKDISTANCE', 8,'THRESHOLD',8);
    
    % This finds lines that don't differ by (5) * THIS IS FROM MATLAB FILE
    % EXCHANGE *
    %lineBreaks = mat2cell(horizProjMinima',1,diff([0,find(diff(horizProjMinima') >= 5),length(horizProjMinima)]));

    % Remove consequtive lines with median
    %lineBreaks = round(cellfun(@median, lineBreaks));

    if (numel(lineBreaks) == 0)
        rects = [loc(1), loc(2), spSize(2), spSize(1)];
        rectangle('Position', [loc(1), loc(2), spSize(2), spSize(1) ], ...
        'LineWidth', 1.5, 'edgecolor', 'red');
        return;
    elseif (numel(lineBreaks) == 1)
        lineBreaks = [0 lineBreaks lineBreaks spSize(2)];
        
    end

    breaks = lineBreaks;
    lineBreaks =  zeros((numel(breaks) - 1),2);
    for i = 1:numel(breaks)-1
        lineBreaks(i,1) = breaks(i);
        lineBreaks(i,2) = breaks(i+1);
    end
    %lineBreaks = reshape(lineBreaks, (numel(lineBreaks)/2), 2);

    % Draw Text bounding boxes on the image
    %  imshow(cnn);
    %  hold on
    %  
    zSize = size(lineBreaks);
    rects = zeros(zSize(1), 4);
    for i = 1:zSize(1)
        if (lineBreaks(i,2) - lineBreaks(i,1) < 3) 
            continue;
        end
        rects(i,:) = [loc(1), loc(2)+ lineBreaks(i, 1), spSize(2), lineBreaks(i,2) - lineBreaks(i,1)];
        rectangle('Position', [loc(1), loc(2)+ lineBreaks(i, 1), spSize(2), lineBreaks(i,2) - lineBreaks(i,1)], ...
        'LineWidth', 1.5, 'edgecolor', 'red');
    end


end