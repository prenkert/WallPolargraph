function linearInterpObject = linearInterp(current_p,target_p, min_step)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load plant_specs.mat dims motor fwdKineSys invKineSys funcs;
load invKineObject.mat inv_kine_object;
load fwdKineObject.mat fwd_kine_object;
load Lookups.mat fwdLookupObject invLookupObject;
load boundaryResults.mat boundaryObject;

threshold_length = funcs.tfStepsToLengthsDelta(min_step); %Same as max dpdstep
threshold = norm([threshold_length threshold_length]);

linearInterpObject = struct();
max_iters = abs(funcs.tfLengthsToStepsDelta(dims.maxStringLength)); % used to preallocate
linearInterpObject.position_log = zeros(max_iters, 2); %Vertical list with x in col1 and y in col2
linearInterpObject.length_log = zeros(max_iters, 2);
dist_to_target_log = zeros(max_iters, 1);

assert(boundaryObject.isInBoundary(target_p), 'Target point not in boundary');

iter = 0;
current_l1 = invLookupObject.inv_kine_lookup.l1(current_p);
current_l2 = invLookupObject.inv_kine_lookup.l2(current_p);
current_l = [current_l1 current_l2];

linearInterpObject.position_log(iter+1, :) = current_p;
linearInterpObject.length_log(iter+1, :) = current_l;
dist_to_target_log(iter+1) = norm(target_p-current_p);

while true
    r = (target_p-current_p)/norm(target_p-current_p); % Return unit vector pointing to target
    current_grad.l1.x = invLookupObject.grad_lookup.l1.x(current_p);
    current_grad.l1.y = invLookupObject.grad_lookup.l1.y(current_p);
    current_grad.l2.x = invLookupObject.grad_lookup.l2.x(current_p);
    current_grad.l2.y = invLookupObject.grad_lookup.l2.y(current_p);

    direction.l1 = dot([current_grad.l1.x current_grad.l1.y],r);
    direction.l2 = dot([current_grad.l2.x current_grad.l2.y],r);

    steps = funcs.tfLengthsToStepsDelta([direction.l1 direction.l2]);

    scaled_steps = round(min_step*steps./min(steps));
    
    iter = iter+1; %Motor moves by scaled_steps
    
    current_l = current_l+funcs.tfStepsToLengthsDelta(scaled_steps);
    current_p = [fwdLookupObject.fwd_kine_lookup.x(current_l), fwdLookupObject.fwd_kine_lookup.y(current_l)];
    

    dist_to_target = norm(target_p-current_p);
    
    
    if dist_to_target<=threshold
        disp('Approached Target within Tolerance')
        break
    elseif dist_to_target>dist_to_target_log(iter)
        disp('Moved away from Target')
        break
    end

        
end
dist_to_target_log(iter+1) = dist_to_target;
linearInterpObject.position_log(iter+1, :) = current_p;
linearInterpObject.length_log(iter+1, :) = current_l;
linearInterpObject.iters = iter;
linearInterpObject.position_log = linearInterpObject.position_log(1:iter+1, :);
linearInterpObject.length_log = linearInterpObject.length_log(1:iter+1, :);



end

