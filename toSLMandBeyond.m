function textStr = toSLMandBeyond(varargin)
% Input: any number of text strings output by OCR 
% Output: text string with the highest probability that it came from region
%   from image


for i = 1:nargin
    % delete all punctuation
    filename{i} = deletePunctStr(varargin{i});
end

for i = 1:nargin
    % Create command file to run SLM
    nid = fopen('commands', 'w');
     fprintf(nid, '%s', ['perplexity -text ', filename{i}]);
     fprintf(nid, '\n%s\n', 'quit');
    
    [status, result] = system('evallm -binary a.binlm < commands');
    
    delete(filename{i});
    % Indicates call did not work
    if (status ~= 0)
        disp('toSLMandBeyond: Error with region');
    end
    numOOVs(i) = findOOVS(result);
    
    fclose(nid);
end

minNumOOVs = min(numOOVs);

% find text region with lowest number of OOVs
for i = 1:nargin
   if (numOOVs(i) == minNumOOVs)
       break;
   end
end

textStr = varargin{i};


