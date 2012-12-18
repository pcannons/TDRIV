function textFile = toSLMandBeyond(region1, region2, region3)
% Input: three file names of OCR output
% Output: text file name with the highest probability that from image

% delete all punctuation
deletePunct(region1);
deletePunct(region2);
deletePunct(region3);

[status, result] = system('evallm -binary a.binlm');
% Indicates call did not work
if (status ~= 0)
    disp('toSLMandBeyond: Error with evallm');
end

[status, result] = system(strcat('perplexity -text ', 'new', region1));
% Indicates call did not work
if (status ~= 0)
    disp('toSLMandBeyond: Error with region1');
end
numOOVs1 = findOOVS(result);

[status, result] = system(strcat('perplexity -text ', 'new', region2));
% Indicates call did not work
if (status ~= 0)
    disp('toSLMandBeyond: Error with region2');
end
numOOVs2 = findOOVS(result);

[status, result] = system(strcat('perplexity -text ', 'new', region3));
% Indicates call did not work
if (status ~= 0)
    disp('toSLMandBeyond: Error with region3');
end
numOOVs3 = findOOVS(result);

[status, result] = system('quit');
% Indicates call did not work
if (status ~= 0)
    disp('toSLMandBeyond: Error with quit');
end


minNumOOVs = min([numOOVs1 numOOVs2 numOOVs3]);

% find text region with lowest number of OOVs
if (minNumOOVs == numOOVs1)
    textFile = region1;
elseif (minNumOOVs == numOOVs2)
    textFile = region2;
elseif (minNumOOVs == numOOVs3)
    textFile = region3;
else
    disp('toSLMandBeyond: minimum not found');
    texFile = 'ERROR';
end


