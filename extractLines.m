function rects = extractLines(subpic, loc)
    % Convert to black and white
    subbw = im2bw(subpic,.5);
    imshow(subbw);

    spSize = size(subpic);

    % Project to Y axis
    horizproj = sum(subbw,2);

    %Remove Adjacent Zeros
    horizproj(horizproj(1:end-1) == 0 & horizproj(2:end) == 0) = 1;

    % This looks for zeros or 'near-zeros'
    horizProjMinima = find(abs(diff(horizproj)) >= std(abs(diff(horizproj))));

    % This finds lines that don't differ by (5) * THIS IS FROM MATLAB FILE
    % EXCHANGE *
    lineBreaks = mat2cell(horizProjMinima',1,diff([0,find(diff(horizProjMinima') >= 10),length(horizProjMinima)]));

    % Remove consequtive lines with median
    lineBreaks = round(cellfun(@median, lineBreaks));

    if (numel(lineBreaks) == 0)
        rects = [loc(1), loc(2), spSize(2), spSize(1)];
        return;
    elseif (numel(lineBreaks) == 1)
        rects = [loc(1), loc(2), spSize(2), spSize(1)];
        return;
    elseif (mod(numel(lineBreaks),2) == 1) % If odd, fashion another zero
        temp = lineBreaks(end);
        lineBreaks(end) = lineBreaks(end-1);
        lineBreaks(end+1)  = temp;
    end

    breaks = lineBreaks;
    lineBreaks =  zeros(numel(breaks)/2,2);
    for i = 1:numel(breaks)/2
        lineBreaks(i,:) = breaks((i-1)*2+1:i*2);
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