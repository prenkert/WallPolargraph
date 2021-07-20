function [l,x,f, exitflags] = invKineSimple(p,invKineSys)
%UNTITLED Summary of this function goes here
%   exitFlag = -3: Nonreal initial guess;
%   exitFlag = -4: String Length Exceeded;

W = invKineSys.dims.W;
weight = invKineSys.approx_weight;
max_string_length = invKineSys.maxStringLength;


p_size = size(p);

if all(p_size(1:2)==[1 2]|p_size(1:2)==[2 1])
    p_i = [p(1) p(2)];
    [sol, exitflags] = invSimple(p_i);
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
            [sol(i,j,:), exitflags(i,j)] = invSimple(p_i);
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

function [x_out, exitflag] = invSimple(p_i)
        phi1 = atan(abs(p_i(2)/p_i(1)));
        l1 = norm(p_i);
        l2v = [W 0]-p_i;
        phi2 = atan(abs(l2v(2)/l2v(1)));
        l2 = norm(l2v);
        
        F_array = [sin(phi1), sin(phi2);-cos(phi1), cos(phi2)]\[weight;0];
        F21 = F_array(1);
        F22 = F_array(2);
        
        x_out = [l1 l2 phi1 phi2 0 F21 F22];
        exitflag = 0;
        if any(x_out(1:2)>max_string_length)
            x_out = NaN(1,7);
            exitflag = -4;
        end
end
  
end

