load invKineObject.mat inv_kine_object;
load fwdKineObject.mat fwd_kine_object;

fwdLookupObject = createLookupsFwd(fwd_kine_object.points_grid_object, fwd_kine_object);
invLookupObject = createLookupsInv(inv_kine_object.points_grid_object, inv_kine_object);

save 'Lookups.mat' fwdLookupObject invLookupObject