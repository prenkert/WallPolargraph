function [p,x,f,exitflags] = fwdKine(l,fwdKineSys)
%UNTITLED Returns P (p.y, p.x) as a function of L = [L1 (left) L2 (right)].
% L can be passed as a single coordinate or array of coordinates with l1,l2
% in the third dimension.
%   exitFlag = -3: Nonreal initial guess; 
eqns_mat = fwdKineSys.eqns_mat;
x0.f = fwdKineSys.x0.f;
lb = fwdKineSys.lb;
ub = fwdKineSys.ub;
W = fwdKineSys.dims.W;

l_size = size(l);
opts = optimoptions('lsqnonlin','Display','off');

if all(l_size(1:2)==[1 2]|l_size(1:2)==[2 1])
    l_i = [l(1) l(2)];
    [sol, exitflags] = lsqWrapper(l_i);
    p.x = sol(1);
    p.y = sol(2);
    x.phi1 = sol(3);
    x.phi2 = sol(4);
    x.alpha = sol(5);
    f.F21 = sol(6);
    f.F22 = sol(7);
else  
    sol = zeros([l_size(1:2) 7]);
    exitflags = zeros([l_size(1:2) 1]);
    for i = 1:l_size(1)
        for j = 1:l_size(2)
            l_i = [l(i,j,1) l(i,j,2)];
            [sol(i,j,:), exitflags(i,j)] = lsqWrapper(l_i);
        end
    end
    p.x = sol(:,:,1);
    p.y = sol(:,:,2);
    x.phi1 = sol(:,:,3);
    x.phi2 = sol(:,:,4);
    x.alpha = sol(:,:,5);
    f.F21 = sol(:, :, 6);
    f.F22 = sol(:, :, 7);
end


    function [x_out, exitflag] = lsqWrapper(l_i)
        x0.x = initX(l_i);
        if not(any(isnan(x0.x)))
            [x_out,~,~,exitflag,~] = lsqnonlin(@(x) eqns_mat(l_i,x),[x0.x x0.f],[lb.x lb.f], [ub.x ub.f], opts);
        else
            x_out = NaN(1,7);
            exitflag = -3;
        end
        
        function x0 = initX(l_i)
            calcPhi = @(a,b,c) acos((a^2+b^2-c^2)/(2*a*b));
            phi1 = calcPhi(W, l_i(1), l_i(2));
            phi2 = calcPhi(W, l_i(2), l_i(1));
             
            px = l_i(1).*cos(phi1);
            py = -l_i(1).*sin(phi1);
            
            x0 = [px py phi1 phi2 0];
        end
    end
  
end

