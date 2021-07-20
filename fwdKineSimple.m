function [p,x,f] = fwdKineSimple(l,fwdKineSys)
%UNTITLED Returns P (p.y, p.x) as a function of L = [L1 (left) L2 (right)].
% L can be passed as a single coordinate or array of coordinates with l1,l2
% in the third dimension. 

W = fwdKineSys.dims.W;
weight = fwdKineSys.approx_weight;
l_size = size(l);

if all(l_size(1:2)==[1 2]|l_size(1:2)==[2 1])
    l_i = [l(1) l(2)];
    x_out = fwdSimple(l_i);
    
    p.x = x_out(1);
    p.y = x_out(2);
    
    x.phi1 = x_out(3);
    x.phi2 = x_out(4);
    x.alpha = x_out(5);
    
    f.F21 = x_out(6);
    f.F22 = x_out(7);

else  
    x_out = zeros([l_size(1:2) 7]);
    for i = 1:l_size(1)
        for j = 1:l_size(2)
            l_i = [l(i,j,1) l(i,j,2)];
            x_out(i,j,:) = fwdSimple(l_i);
        end
    end
    p.x = x_out(:,:,1);
    p.y = x_out(:,:,2);
    
    x.phi1 = x_out(:,:,3);
    x.phi2 = x_out(:, :, 4);
    x.alpha = x_out(:, :, 5);
    
    f.F21 = x_out(:,:,6);
    f.F22 = x_out(:,:,7);
end


function x_out = fwdSimple(l_i)
        calcPhi = @(a,b,c) acos((a^2+b^2-c^2)/(2*a*b));
        phi1 = calcPhi(W, l_i(1), l_i(2));
        phi2 = calcPhi(W, l_i(2), l_i(1));

        px = l_i(1).*cos(phi1);
        py = -l_i(1).*sin(phi1);
        
        F_array = [sin(phi1), sin(phi2);-cos(phi1), cos(phi2)]\[weight;0];
        F21 = F_array(1);
        F22 = F_array(2);

        x_out = [px py phi1 phi2 0 F21 F22];
end
  
end

