function subPics = getRegions(img, rects)
    rSize = size(rects);
    subPics = cell(rSize(1),1);
    for i = 1:rSize(1) 
        subPics{i} = img(rects(i,2):rects(i,2)+rects(i,4)-1, rects(i,1):rects(i,1)+rects(i,3)-1);
    end

end