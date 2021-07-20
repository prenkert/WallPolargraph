function [l,x,f,exitflags] = invKine(p,invKineSys)
%UNTITLED Summary of this function goes here
%   exitFlag = -3: Nonreal initial guess;
%   exitFlag = -4: String Length Exceeded;
eqns_mat = invKineSys.eqns_mat;
x0.f = invKineSys.x0.f;
lb = invKineSys.lb;
ub = invKineSys.ub;
W = invKineSys.dims.W;

p_size = size(p);
opts = optimoptions('lsqnonlin','Display','off','FunctionTolerance', 1e-10);

if all(p_size(1:2)==[1 2]|p_size(1:2)==[2 1])
    p_i = [p(1) p(2)];
    [sol, exitflags] = lsqWrapper(p_i);
    l.l1 = sol(1);
    l.l2 = sol(2);
    x.phi1 = sol(3);
    x.phi2 = sol(4);
    x.alpha = sol(5);
    f.F21 = sol(6);
    f.F22 = sol(7);

else
    sol = zeros([p_size(1:2) 7]);
    exitflags = zeros([p_size(1:2) 1]);
    for i = 1:p_size(1)
        for j = 1:p_size(2)
            p_i = [p(i,j,1) p(i,j,2)];
            [sol(i,j,:), exitflags(i,j)] = lsqWrapper(p_i);
        end
    end
    l.l1 = sol(:,:,1);
    l.l2 = sol(:,:,2);
    x.phi1 = sol(:,:,3);
    x.phi2 = sol(:,:,4);
    x.alpha = sol(:,:,5);
    f.F21 = sol(:,:,6);
    f.F22 = sol(:,:,7);
end

    function [x_out, exitflag] = lsqWrapper(p_i)
        x0.x = initX(p_i);
        if not(any(isnan(x0.x)))
            [x_out,~,~,exitflag,~] = lsqnonlin(@(x) eqns_mat(p_i,x),[x0.x x0.f],[lb.x lb.f], [ub.x ub.f], opts);
        else
            x_out = NaN(1,7);
            exitflag = -3;
        end
        
        function x0 = initX(p_i)
            phi1 = atan(abs(p_i(2)/p_i(1)));
            l1 = norm(p_i);
            l2v = [W 0]-p_i;
            phi2 = atan(abs(l2v(2)/l2v(1)));
            l2 = norm(l2v);
            
            x0 = [l1 l2 phi1 phi2 0];
        end
    end
  
end

