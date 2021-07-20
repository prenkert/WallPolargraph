function lookupsObject = createLookupsInv(points_grid_object,inv_kine_object)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
x = points_grid_object.x_list;
y = points_grid_object.y_list;
l1 = inv_kine_object.l.l1;
l2 = inv_kine_object.l.l2;

inv_kine_lookup.l1 = griddedInterpolant(x',y',l1');
inv_kine_lookup.l2 = griddedInterpolant(x',y',l2');

[grad.l1.x, grad.l1.y] = gradient(l1);
[grad.l2.x, grad.l2.y] = gradient(l2);

grad_lookup.l1.x = griddedInterpolant(x',y',grad.l1.x');
grad_lookup.l1.y = griddedInterpolant(x',y',grad.l1.y');
grad_lookup.l2.x = griddedInterpolant(x',y',grad.l2.x');
grad_lookup.l2.y = griddedInterpolant(x',y',grad.l2.y');

lookupsObject.points_grid_object = points_grid_object;
lookupsObject.inv_kine_lookup = inv_kine_lookup;
lookupsObject.grad_lookup = grad_lookup;

end

