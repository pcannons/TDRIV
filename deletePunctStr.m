function filename = deletePunctStr(textFileIn)
% Replaces all punctuation in textFile with ' '

filename = int2str(floor(10000*rand));


nid = fopen(filename, 'w');

space = ' ';
textFile = char(textFileIn);
[m n] = size(textFile);

for i = 1:n
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
        newArray(i) = textFile(i);  
    
    end

end

fprintf(nid, '%s', lower(newArray));
fclose('all');

