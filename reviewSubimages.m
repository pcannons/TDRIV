function subimages = reviewSubimages(subimages)

    for i = 1:numel(subimages)
        disp(i);
        imshow(subimages{i});
        pause;
    end

end