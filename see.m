for i=1:length(feature_struct.features)
    for j=1:length(feature_struct.features{i})
    
        if(feature_struct.text_candidate{i}(j) == 1)
            imshow(feature_struct.subpics{i}{j})
            l = feature_struct.text{i}{j}{:};
            feature_struct.text_candidate{i}(j)
            l{:}
            pause
        end
    
    end
end