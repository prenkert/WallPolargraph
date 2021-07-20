%% Load all plant_specs into main workspace
load plant_specs.mat;
addpath('OSSoftware');
addpath('VECTORS');

%% Define Points Grid Objects
points_grid_object_inv = pointsGridInv(0.1);
points_grid_object_fwd = pointsGridFwd(0.1);

%% Generate Kinematics and Lookup Tables
kine_gen_flag = true;

if kine_gen_flag
    inv_kine_object = struct();
    [inv_kine_object.l, inv_kine_object.x, inv_kine_object.f, inv_kine_object.errorflags] = invKine(points_grid_object_inv.points_grid, invKineSys);
    inv_kine_object.points_grid_object = points_grid_object_inv;
    save 'invKineObject.mat' inv_kine_object;
    
    fwd_kine_object = struct();
    [fwd_kine_object.p,fwd_kine_object.x,fwd_kine_object.f,fwd_kine_object.exitflags] = fwdKine(points_grid_object_fwd.points_grid,fwdKineSys);
    fwd_kine_object.points_grid_object = points_grid_object_fwd;
    save 'fwdKineObject.mat' fwd_kine_object;
    
    fwdLookupObject = createLookupsFwd(fwd_kine_object.points_grid_object, fwd_kine_object);
    invLookupObject = createLookupsInv(inv_kine_object.points_grid_object, inv_kine_object);

    save 'Lookups.mat' fwdLookupObject invLookupObject
else
    load invKineObject.mat inv_kine_object;
    load fwdKineObject.mat fwd_kine_object;
    load Lookups.mat fwdLookupObject invLookupObject;
end

%% Generate Boundary
close all
boundaryObject = boundaryAnalysis(points_grid_object_inv, inv_kine_object,...
    'plotIntermediateFigures', false,...
    'plotFinalBoundary', true);

