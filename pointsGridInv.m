function pointsGridObject = pointsGridInv(delta)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    load plant_specs.mat dims;

    pointsGridObject.delta = delta;
    pointsGridObject.x_min = 0;
    pointsGridObject.x_max = dims.W;
    pointsGridObject.x_vals = pointsGridObject.x_min:delta:pointsGridObject.x_max;

    pointsGridObject.y_min = -dims.H;
    pointsGridObject.y_max = 0;
    pointsGridObject.y_vals = pointsGridObject.y_min:delta:pointsGridObject.y_max;
    [x_list, y_list] = meshgrid(pointsGridObject.x_vals,pointsGridObject.y_vals);
    pointsGridObject.x_list = x_list;
    pointsGridObject.y_list = y_list;
    pointsGridObject.points_grid = cat(3,x_list, y_list);
    
    pointsGridObject.axis_limits = [pointsGridObject.x_min pointsGridObject.x_max pointsGridObject.y_min pointsGridObject.y_max];
end

