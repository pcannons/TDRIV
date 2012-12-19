function oovs = findOOVS(region)
% Input: text candidate regiobn
% Output: number of out of vocabulary words

oovs = '00';

[m n] = size(region);
if (n == 0)
    oovs = '999';
end

for i = 1:n
    if (region(i) == 'O')
        if (region(i + 1) == 'O')
            if (region(i + 2) == 'V')
                if (region(i + 3) == 's')
                    % Check for any possible words
                    if (region(i + 6) == '-')
                        oovs = '999';
                        break;
                    end
                    if (region(i - 6) == 'n' || region(i - 7) == 'n')
                        oovs = '999';
                        break;
                    end
                    % There are some identified words
                    i = i - 2;
                    while (region(i) ~= ')')
                        i = i - 1;
                    end
                    i = i + 2;
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
