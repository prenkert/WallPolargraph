%%
points_grid_object_inv = pointsGridInv(0.01);

load plant_specs.mat invKineSys

% inv_kine_object = struct();
% [inv_kine_object.l, inv_kine_object.x, inv_kine_object.f, inv_kine_object.errorflags] = invKine(points_grid_object_inv.points_grid, invKineSys);
% inv_kine_object.points_grid_object = points_grid_object_inv;
% save 'invKineObject.mat' inv_kine_object

load invKineObject.mat inv_kine_object;

%%
points_grid_object_fwd = pointsGridFwd(0.01);

load plant_specs.mat fwdKineSys

% fwd_kine_object = struct();
% [fwd_kine_object.p,fwd_kine_object.x,fwd_kine_object.f,fwd_kine_object.exitflags] = fwdKine(points_grid_object_fwd.points_grid,fwdKineSys);
% fwd_kine_object.points_grid_object = points_grid_object_fwd;
% save 'fwdKineObject.mat' fwd_kine_object;

load fwdKineObject.mat fwd_kine_object;

%%
close all
boundaryObject = boundaryAnalysis(points_grid_object_inv, inv_kine_object,...
    'plotIntermediateFigures', false,...
    'plotFinalBoundary', true);