function oovs = findOOVS(region)
% Input: text candidate regiobn
% Output: number of out of vocabulary words

oovs = '0';

[m n] = size(region);

for i = 1:n
    if (region(i) == 'O')
        if (region(i + 1) == 'O')
            if (region(i + 2) == 'V')
                if (region(i + 3) == 's')
                    i = i - 2;
                    while (region(i) ~= ' ')
                        i = i - 1;
                    end
                    i = i + 1;
                    while (region(i) ~= ' ')
                        oovs = strcat(oovs, region(i));
                        i = i + 1;
                    end
                end
            end
        end
    end
end
oovs = str2double(oovs);
