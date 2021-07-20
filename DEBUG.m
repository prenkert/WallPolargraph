coord_pairs_test = coord_pairs(~cellfun(@isempty, coord_pairs));
for i = 1:length(coord_pairs_test)
    try
        c = coord_pairs_test{i};
        disp([c(:,1), -c(:,2)])
    catch
        fprintf("Error in index %d", i);
    end
end