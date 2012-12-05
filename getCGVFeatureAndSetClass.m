function [ CGV_Feature_Array Y ] = getCGVFeatureAndSetClass( region )
%GETCGVFEATURES Summary of this function goes here
%   Detailed explanation goes here
    
    % For key input for making datasets
    YES = 121;
    NO = 110;
    ALL_NO = 113;
    ALL_YES = 13;
    
    % If no text in region
    skip_region = false;
    
    % Feature window size
    window_square_size = 16;
    
    % Amount to obtain each feature window
    slide_size = 4;
      
    % Show the original image
    subplot(1,3,1);
    imshow(region);
    axis image;
    
    region = double(region);
  
    
    % Height of entire region
    height = size(region,1);
    
    % Resize window to be of feature window height
    if(height ~= window_square_size)
        region = imresize(region, [window_square_size NaN]);
    end
    
    % Show the scale image
    subplot(1,3,2);
    imshow(uint8(region));
    axis image;
   
    % Calculage graident of region
    region_gradient = gradient(region);
    
    % Global mean
    GM = mean(region_gradient(:));  
    % Global variance
    GV = var((region_gradient(:)));
    
    % Obtain the new width after scaling to window_square_size height
    region_width = size(region,2);
    
    % Number of feature windows
    num_feature_windows = floor((region_width - (window_square_size - slide_size))/slide_size);
    
    % Precalculate all the indicies of features windows
    feature_indicies = cell(1,num_feature_windows);
    for i = 1:num_feature_windows
        feature_indicies{i} = 1+4*(i-1):16+4*(i-1);
    end
    
    % Vertical indicies which are always the same because it's a square
    vertical_indicies = 1:window_square_size;
    
    
    I = cell(1, num_feature_windows);
    
    % Store all the sliding windows into I
    for i=1:num_feature_windows
        I{i} = region(vertical_indicies, feature_indicies{i});
    end
          
    % Local window size
    local_window_size = 9;
    start_pixel = floor(local_window_size/2);
    end_pixel = window_square_size - start_pixel;
    
    CGV_Features = cell(num_feature_windows,1);
    Y = zeros(num_feature_windows,1);
    
    % Calculate the features for each window
	for i=1:num_feature_windows
        CGV_Features{i} = zeros(end_pixel-start_pixel,end_pixel-start_pixel);
        
        region_gradient = gradient(I{i});
        
        for k=start_pixel+1:end_pixel
            for l=start_pixel+1:end_pixel
                local_region = region_gradient(k-start_pixel:k+start_pixel, l-start_pixel:l+start_pixel);

                % Local mean
                LM = mean(local_region(:));

                % Local variance
                LV = var(local_region(:));

                % Constant gradient variance
                CGV_Features{i}(k-start_pixel,l-start_pixel) = (region_gradient(k,l) - LM)*sqrt(GV/LV);
            end
        end
        
        CGV_Features{i} = CGV_Features{i}(:)';
        
        % Show the scale image
        subplot(1,3,3); 
        imshow(uint8(I{i}));

        %Draw scaled image and raw rectangle on top
        subplot(1,3,2);
        hold on
        %Rectangle of current feature window
        box = [1+(i-1)*slide_size 1 window_square_size window_square_size];
        rectangle('Position', box,'LineWidth',2,'LineStyle','--', 'EdgeColor', 'r');
        hold off
        
        % If space was clicked, no_text is ture, skips keypreses
        if(~skip_region)
            valid_key = false;
            % Checks for y,n,space to see if feature window has text
            while(~valid_key)
                
                [ch, tim] = getKey(1);
                
                if(ch == YES)
                    Y(i) = 1;
                    valid_key = true;
                elseif(ch == NO)
                    valid_key = true;
                elseif(ch == ALL_NO)
                    % If no text in window, space skips checks for this
                    % region
                    skip_region = true;
                    valid_key = true;
                elseif(ch == ALL_YES)
                    % If all image text
                    skip_region = true;
                    Y = ones(size(Y));
                    valid_key = true;
                else
                   fprintf('### No valid key hit, try again. ###\n'); 
                end
            end
            
            fprintf('%d presses to go for this region.\n', num_feature_windows-i);
        end
        
       
        
    end
    
    CGV_Feature_Array = zeros(length(I), (window_square_size/2)^2);
    
    for i=1:size(CGV_Features)
        CGV_Feature_Array(i,:) = CGV_Features{i};
    end
    
    close all;
end

