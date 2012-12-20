%% TO USE
% Hit y for when there is a character, n for when there isn't and space
% for when the whole region doesn't contain text

%% Initialization
clear ; close all; clc

%% To train place all images in the directory/directories in variable paths
paths = {'images/'};

% Extensions of images to check for in the paths folder
extensions = {'.jpeg' '.jpg' '.png' '.gif' '.bmp'};

% This is where the model will be stored afterwards for prediction
model = [];
x1 = [1 2 1];
x2 = [0 4 -1];

% Directory name where intermediate steps are saved
conf.dataDir = 'data/';

%% Create data folder
if ~exist(conf.dataDir, 'dir')
  mkdir(conf.dataDir);
end

conf.imagesPath = fullfile(conf.dataDir, 'images.mat') ;
conf.modelPath = fullfile(conf.dataDir, 'model.mat');

conf.trainSVM = true;

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
            im = feature_struct.images{i};
            % Scale down very large images
            [m, ~] = size(im);
            if (m > 400)
                im = imresize(im, 400 / m);
            end
            [m n] = size(im);
            if (n > 400)
                im = imresize(im, 400 / n);
            end

            [subimages locs] = textcandidate(im, 'false');
            [subimages locs] = pruneCandidates(subimages, locs);

            subpics = {}; 

            for j = 1:numel(subimages)
                rects = extractLines(subimages{j}, locs(j,:), 'false');
                subpics = [subpics; getRegions(im, rects)];  
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

%%%%

% Preinitialize feature vector
feature_struct.features = cell(size(feature_struct.images));
feature_struct.class = cell(size(feature_struct.images));

tic

%% Go through each region and calculate the features
for i=1:length(feature_struct.images)
    
    conf.imagePath = fullfile(conf.dataDir, [feature_struct.names{i} '.mat']) ;
    
    if ~exist(conf.imagePath , 'file')
        for j=1:length(feature_struct.subpics{i})
            % Calculate features for this regionusing getCGVFeatures
            [CGV Y] = getCGVFeatureAndSetClass(feature_struct.subpics{i}{j});

            % Store CGV features for every feature
            feature_struct.features{i}{j} = CGV;
            feature_struct.class{i}{j} = Y; 
            
            % Any NaN elements? Indicates a problem
            nan = isnan(CGV);
            
            if(sum(nan(:)) == 1)
             fprintf('Image name: %s\n', feature_struct.names{i});
             error('############ NaN features found. ############\n');
            end
        end
        features = feature_struct.features{i};
        class = feature_struct.class{i};
        
        save(conf.imagePath , 'features', 'class');
    else
        features = load(conf.imagePath, 'features');
        class = load(conf.imagePath, 'class');

        feature_struct.features{i} = features.features;
        feature_struct.class{i} = class.class;
    end
end

fprintf('Time to get GCV features: %d seconds. \n', ceil(toc));
%%%

if(conf.trainSVM)
    t = feature_struct.features';
    g = [t{:}]';

    % Get the X row features
    X = cell2mat(g);

    t = feature_struct.class';
    g = [t{:}]';

    % Get the result
    y = cell2mat(g);

    % Store half the features in X, the other half in Xval (if odd, add 1)
    if(mod(size(X,1),2)~= 0)
        indicies = [1:floor(size(X,1)/2);  floor(size(X,1)/2)+1:size(X,1)-1];
    else
        indicies = [1:size(X,1)/2;  size(X,1)/2+1:size(X,1)];
    end

    % Split the dataset in two for M-fold validation
    Xval = X(indicies(1,:),:);
    yval = y(indicies(1,:),:);

    X = X(indicies(2,:),:);
    y = y(indicies(2,:),:);

    tic
    % Find optimal SVM parameters
    [C, sigma] = dataset3Params(X, y, Xval, yval);

    fprintf('Time to find optimal C and sigma: %d seconds. \n', ceil(toc));

    sigma = 3;
    C = 10;
    
    tic
    % Train the SVM
    model = svmTrain(X, y, C, @(x1, x2) gaussianKernel(x1, x2, sigma));
    save(conf.modelPath, 'model');
    fprintf('Time to train SVM: %d seconds. \n', ceil(toc));
end
