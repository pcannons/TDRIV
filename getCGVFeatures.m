function [ CGV_Feature_Array Y ] = getCGVFeatures( region )
%GETCGVFEATURES Summary of this function goes here
%   Detailed explanation goes here
    
    % Feature window size
    window_square_size = 16;
    
    % Amount to obtain each feature window
    slide_size = 4;
    
    region = double(region);
    
    % Height of entire region
    height = size(region,1);
    
    % Resize window to be of feature window height
    if(height ~= window_square_size)
        region = imresize(region, [window_square_size NaN]);
    end
    
    % Calculage graident of region
    g_mag = gradient(region);
    
    % Global mean
    GM = mean(g_mag(:));  
    % Global variance
    GV = var((g_mag(:)));
    
    % Obtain the new width after scaling to window_square_size height
    region_width = size(region,2);
    
    % Number of feature windows
    num_feature_windows = floor((region_width - (window_square_size - slide_size))/slide_size);
    
    % Precalculate all the indicies of features windows
    feature_indicies = cell(1,num_feature_windows);
    parfor i = 1:num_feature_windows
        feature_indicies{i} = 1+4*(i-1):16+4*(i-1);
    end
    
    % Vertical indicies which are always the same because it's a square
    vertical_indicies = 1:window_square_size;
    
    
    I = cell(1, num_feature_windows);
    
    % Store all the sliding windows into I
    parfor i=1:num_feature_windows
        I{i} = region(vertical_indicies, feature_indicies{i});
    end
          
    % Local window size
    local_window_size = 9;
    start_pixel = floor(local_window_size/2);
    end_pixel = window_square_size - start_pixel;
    
    CGV_Features = cell(num_feature_windows,1);
    Y = cell(num_feature_windows,1);
    
    % Calculate the features for each window
	for i=1:num_feature_windows
        CGV_Features{i} = zeros(end_pixel-start_pixel,end_pixel-start_pixel);
        
        [rg_x rg_y]= gradient(I{i});
        g_mag = arrayfun(@hypot, rg_x, rg_y);
        
        for k=start_pixel+1:end_pixel
            for l=start_pixel+1:end_pixel
                local_region = g_mag(k-start_pixel:k+start_pixel, l-start_pixel:l+start_pixel);

                % Local mean
                LM = mean(local_region(:));

                % Local variance
                LV = var(local_region(:));

                 if(LV == 0)
                    CGV_Features{i}(k-start_pixel,l-start_pixel) = 0;
                else
                    CGV_Features{i}(k-start_pixel,l-start_pixel) = (g_mag(k,l) - LM)*sqrt(GV/LV);
                end
            end
        end
        
        CGV_Features{i} = CGV_Features{i}(:)';
        CGV_Features{i}(isnan(CGV_Features{i})) = 0;
    end
    
    CGV_Feature_Array = zeros(length(I), (window_square_size/2)^2);
    
    for i=1:size(CGV_Features)
        CGV_Feature_Array(i,:) = CGV_Features{i};
    end
end

