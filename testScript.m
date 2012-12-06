%% Initialization
clear ; close all; clc

%% To test place all images in the directory/directories in variable paths
paths = {'timages/'};

% Extensions of images to check for in the paths folder
extensions = {'.jpeg' '.jpg' '.png' '.gif' '.bmp'};

% Directory name where intermediate steps are saved
conf.dataDir = 'testdata/';

% Various paths
conf.imagesPath = fullfile(conf.dataDir, 'images.mat') ;
conf.modelPath = fullfile('model/', 'model.mat');

% Load the model
model = load(conf.modelPath);
model = model.model;

%% Create data folder
if ~exist(conf.dataDir, 'dir')
  mkdir(conf.dataDir);
end

% Flag for whether or not a parameter has been loaded
loaded = false;

% Feature struct
feature_struct.images = {};
feature_struct.names = {};

% Calculates number of images
for i=1:size(paths,2)
    % Gets the files in the directory
    files = dir(char(paths(i)));
    % Loops through path directory
    for j=1:length(files)
        % Only grab files with above extensions
        for ext=1:length(extensions)
            if(strfind(files(j).name, extensions{ext}))
                feature_struct.names{end + 1} = files(j).name;       
                break;
            end
        end
    end
end

feature_struct.subpics = cell(size(feature_struct.names));

%% Load images and their regions
% Boolean of whether or not the images need to be extracted
loadAndExtractBoolean = true;

% If images saved, load
if exist(conf.imagesPath, 'file')
    old_feature_struct = load(conf.imagesPath, 'feature_struct');
    % If nothing changed, load and breakout of loop
    if(length(old_feature_struct.feature_struct.names) == length(feature_struct.names))
        load(conf.imagesPath);
        loaded = true;
        fprintf('%d images loaded.\n\n', size(feature_struct.images,2));
        loadAndExtractBoolean = false;
    else
        % If number of images changed, delete extracted data
        delete(conf.imagesPath);
        feature_struct.images = feature_struct.images;
    end
end
   
% If number of images changed or the data doesn't exist, extract regions
if(loadAndExtractBoolean)
    % Stores all images in a column vector feature_struct.images
    for i=1:size(paths,2)
        % Gets the files in the directory
        files = dir(char(paths(i)));
        % Loops through path directory and stores all the images in the cell feature_struct.images
        for j=1:length(files)
            % Only grab files with above extensions
            for ext=1:length(extensions)
                if(files(j).isdir)
                    break;
                end
                
                if(strfind(files(j).name, extensions{ext}))
                    im = imread(strcat(char(paths(i)), files(j).name));

                    % Only store grayscale images
                    if(size(size(im),2) > 2)
                        feature_struct.images{end + 1} = rgb2gray(im);
                    else
                        feature_struct.images{end + 1} = im;
                    end

                    break;
                end
            end
        end
    end

    fprintf('%d images loaded.\n\n', size(feature_struct.images,2));
    
     % If doesn't exist or number of images changed extract regions
    for i=1:length(feature_struct.images)
        conf.regionPath = fullfile(conf.dataDir, [feature_struct.names{i} '-subpics.mat']) ;

        if ~exist(conf.regionPath , 'file')
            [subimages locs] = textcandidate(feature_struct.images{i});
            [subimages locs] = pruneCandidates(subimages, locs);

            subpics = {}; 

            for j = 1:numel(subimages)
                rects = extractLines(subimages{j}, locs(j,:));
                close all;
                subpics = [subpics; getRegions(feature_struct.images{i}, rects)];  
            end
            fprintf('%d regions extracted from image #%d.\n', length(subpics), i);
            subpics(cellfun(@isempty,subpics)) = [];
            feature_struct.subpics{i} = subpics;
        
            save(conf.regionPath , 'subpics');
        
        else
            %Load subpics
            subpics = load(conf.regionPath, 'subpics');
            feature_struct.subpics{i} = subpics.subpics;
            fprintf('%d regions loaded for image #%d.\n', length(subpics.subpics), i);
        end
    end
end

if(~loaded) 
    save(conf.imagesPath, 'feature_struct') 
end;

fprintf('Regions loaded.\n');

% Preinitialize feature vector
feature_struct.features = cell(size(feature_struct.images));
feature_struct.class = cell(size(feature_struct.images));

tic

%% Go through each region and calculate the features
for i=1:length(feature_struct.images)
        for j=1:length(feature_struct.subpics{i})
            % Calculate features for this regionusing getCGVFeatures
            CGV = getCGVFeatures(feature_struct.subpics{i}{j});

            % Store CGV features for every feature
            feature_struct.features{i}{j} = CGV;
            
            % Any NaN elements? Indicates a problem
            nan = isnan(CGV);
            
            if(sum(nan(:)) == 1)
             fprintf('Image name: %s\n', feature_struct.names{i});
             error('############ NaN features found. ############\n');
            end
        end
        features = feature_struct.features{i};
end

fprintf('Time to get GCV features: %d seconds. \n', ceil(toc));

% SVM Results
% Number of images
feature_struct.text_candidate = cell(1,length(feature_struct.features));

% For each image
for i=1:length(feature_struct.features)
    % For each subpic
    feature_struct.text_candidate{i} = zeros(size(feature_struct.features{i}));
    
    
    
%     for j=1:length(feature_struct.features{i})
%         % For each feature
%         feature_struct.class{i}{j} = zeros(size(feature_struct.features{i}{j},1),1);
%     end
end

for i=1:length(feature_struct.features)
    for j=1:length(feature_struct.features{i})
        set = svmPredict(model, feature_struct.features{i}{j});
        
        prob = mean(set);
        
        if(prob > 0.67)
            feature_struct.text_candidate{i}(j) = 1;
        else
            feature_struct.text_candidate{i}(j) = 0;
        end

        fprintf('Probabilty of text: %f\n', prob);
        imshow(feature_struct.subpics{i}{j});
        pause
    end   
end

close all