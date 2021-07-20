function pointsGridObject = pointsGridFwd(delta)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    load plant_specs.mat dims;

    pointsGridObject.delta = delta;
    pointsGridObject.l_min = 0+delta;
    pointsGridObject.l_max = dims.maxStringLength;
    pointsGridObject.l_vals = pointsGridObject.l_min:delta:pointsGridObject.l_max;

    [l1_list, l2_list] = meshgrid(pointsGridObject.l_vals,pointsGridObject.l_vals);
    pointsGridObject.l1_list = l1_list;
    pointsGridObject.l2_list = l2_list;
    pointsGridObject.points_grid = cat(3,l1_list, l2_list);
end

