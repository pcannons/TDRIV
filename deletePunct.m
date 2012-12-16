function deletePunct(textFile)
% Replaces all punctuation in textFile with ' '

rid = fopen(textFile, 'r');
nid = fopen(strcat('new',textFile), 'w');

fileArray = fscanf(rid, '%c');

[m n] = size(fileArray);
space = ' ';


for i = 1:n
    if (fileArray(i) == '.')
        newArray(i) = space;
    elseif (fileArray(i) == '!')
        newArray(i) = space;
    elseif (fileArray(i) == '"')
        newArray(i) = space;
    elseif (fileArray(i) == '?')
        newArray(i) = space;
    elseif (fileArray(i) == ',')
        newArray(i) = space;
    elseif (fileArray(i) == '&')
        newArray(i) = space;
    elseif (fileArray(i) == '*')
        newArray(i) = space;
    elseif (fileArray(i) == '=')
        newArray(i) = space;
    elseif (fileArray(i) == '-')
        newArray(i) = space;
    elseif (fileArray(i) == '+')
        newArray(i) = space;
    elseif (fileArray(i) == '~')
        newArray(i) = space;
    elseif (fileArray(i) == '/')
        newArray(i) = space;
    else
        newArray(i) = fileArray(i);  
    
    end

end

fprintf(nid, '%s', newArray);
fclose('all');

