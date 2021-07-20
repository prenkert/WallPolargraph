load 'plant_specs.mat' fwdKineSys dims
load boundaryResults.mat boundaryObject

points_grid_object = pointsGridInv(0.01); % Only using this one for axis limits
%current_p = fwdKine([dims.maxStringLength-.1 dims.maxStringLength-.1], fwdKineSys);
%current_p = [current_p.x, current_p.y];
current_p = [0.4 -0.8];

target_p = [0.5 -0.7];

lin_interp_obj = linearInterp(current_p, target_p, 10);

close all
figure
hold on
plot(boundaryObject.poly(:,1), boundaryObject.poly(:,2));
plot([current_p(1);target_p(1)],[current_p(2);target_p(2)],'-r')
plot(lin_interp_obj.position_log(:,1), lin_interp_obj.position_log(:,2), '.-b')

axis(points_grid_object.axis_limits, 'square');
hold off

