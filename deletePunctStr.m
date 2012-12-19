function filename = deletePunctStr(textFileIn)
% Replaces all punctuation in textFile with ' '

filename = int2str(floor(10000*rand));


nid = fopen(filename, 'w');

newArray = [];
space = ' ';
textFile = char(textFileIn);
[m n] = size(textFile);

for i = 1:n
    textFile(i)
    if (textFile(i) == '.')
        newArray(i) = space;
    elseif (textFile(i) == '!')
        newArray(i) = space;
    elseif (textFile(i) == '"')
        newArray(i) = space;
    elseif (textFile(i) == '''')
        newArray(i) = space;
    elseif (textFile(i) == '?')
        newArray(i) = space;
    elseif (textFile(i) == ',')
        newArray(i) = space;
    elseif (textFile(i) == '&')
        newArray(i) = space;
    elseif (textFile(i) == '*')
        newArray(i) = space;
    elseif (textFile(i) == '=')
        newArray(i) = space;
    elseif (textFile(i) == '-')
        newArray(i) = space;
    elseif (textFile(i) == '+')
        newArray(i) = space;
    elseif (textFile(i) == '~')
        newArray(i) = space;
    elseif (textFile(i) == '/')
        newArray(i) = space;
    elseif (textFile(i) == ':')
        newArray(i) = space;
    elseif (textFile(i) == ';')
        newArray(i) = space;
    elseif (textFile(i) == '$')
        newArray(i) = space;
    elseif (textFile(i) == '(')
        newArray(i) = space;
    elseif (textFile(i) == ')')
        newArray(i) = space;
    elseif (textFile(i) == '[')
        newArray(i) = space;
    elseif (textFile(i) == ']')
        newArray(i) = space;
    elseif (textFile(i) == '{')
        newArray(i) = space;
    elseif (textFile(i) == '}')
        newArray(i) = space;
    elseif (textFile(i) == '#')
        newArray(i) = space;
    elseif (textFile(i) == '%')
        newArray(i) = space;
    elseif (textFile(i) == '_')
        newArray(i) = space;
    else
        newArray(i) = lower(textFile(i));
    
    end

end

fprintf(nid, '%s', newArray);
fclose('all');

