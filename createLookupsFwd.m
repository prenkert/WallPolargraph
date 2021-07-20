function lookupsObject = createLookupsFwd(points_grid_object,fwd_kine_object)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
l1 = real(points_grid_object.l1_list);
l2 = real(points_grid_object.l2_list);
x = real(fwd_kine_object.p.x);
y = real(fwd_kine_object.p.y);

fwd_kine_lookup.x = griddedInterpolant(l1',l2',x');
fwd_kine_lookup.y = griddedInterpolant(l1',l2',y');

[grad.x.l1, grad.x.l2] = gradient(x);
[grad.y.l1, grad.y.l2] = gradient(y);

grad_lookup.x.l1 = griddedInterpolant(l1',l2',grad.x.l1');
grad_lookup.x.l2 = griddedInterpolant(l1',l2',grad.x.l2');
grad_lookup.y.l1 = griddedInterpolant(l1',l2',grad.y.l1');
grad_lookup.y.l2 = griddedInterpolant(l1',l2',grad.y.l2');

lookupsObject.points_grid_object = points_grid_object;
lookupsObject.fwd_kine_lookup = fwd_kine_lookup;
lookupsObject.grad_lookup = grad_lookup;

end

