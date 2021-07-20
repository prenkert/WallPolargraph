function [x,f,exitflags] = forwardKine(l,fwdKineSys)
%UNTITLED Summary of this function goes here
%   exitFlag = -3: Nonreal initial guess;
%   exitFlag = 
eqns_mat = fwdKineSys.eqns_mat;
x0.f = fwdKineSys.x0.f;
lb = fwdKineSys.lb;
ub = fwdKineSys.ub;
W = fwdKineSys.dims.W;

initPhi = @(l_i,oppL) acos((norm([W l_i(1) l_i(2)])-2*oppL^2)/(2*prod([W l_i(1) l_i(2)])/oppL));
initX = @(l_i)[initPhi(l_i,l_i(2)) initPhi(l_i,l_i(1)) 0];

l_size = size(l);
opts = optimoptions('lsqnonlin','Display','off');
if l_size(1) == 1
    l_i = l;
    x0.x = initX(l_i);
    if isreal(x0.x)
        [sol,~,~,exitflags,~] = lsqnonlin(@(x) eqns_mat(l_i,x),[x0.x x0.f],[lb.x lb.f], [ub.x ub.f], opts);
    else
        sol = NaN(1,5);
        exitflags = -3;
    end
    x.phi1 = sol(1);
    x.phi2 = sol(2);
    x.alpha = sol(3);
    f.F21 = sol(4);
    f.F22 = sol(5);


elseif l_size(2) == 2
    sol = zeros(l_size(1),5);
    exitflags = zeros(l_size(1),1);
    for i = 1:l_size(1)
        l_i = l(i,:);
        x0.x = initX(l_i);
        if isreal(x0.x)
            [x_out,~,~,exitflag,~] = lsqnonlin(@(x) eqns_mat(l_i,x),[x0.x x0.f],[lb.x lb.f], [ub.x ub.f], opts);
            sol(i,:) = x_out;
            exitflags(i) = exitflag;
        else
            sol(i,:) = NaN(1,5);
            exitflags(i) = -3;
        end
    end
    x.phi1 = sol(:,1);
    x.phi2 = sol(:,2);
    x.alpha = sol(:,3);
    f.F21 = sol(:,4);
    f.F22 = sol(:,5);


else
    sol = zeros([l_size(1:2) 5]);
    exitflags = zeros([l_size(1:2) 1]);
    for i = 1:l_size(1)
        for j = 1:l_size(2)
            l_i = l(i,j,:);
            x0.x = initX(l_i);
            if isreal(x0.x)
                [x_out,~,~,exitflag,~] = lsqnonlin(@(x) eqns_mat(l_i,x),[x0.x x0.f],[lb.x lb.f], [ub.x ub.f], opts);
                sol(i,j,:) = x_out;
                exitflags(i,j) = exitflag;
            else
                sol(i,j,:) = NaN(1,5);
                exitflags(i,j) = -3;
            end
        end
    end
    x.phi1 = sol(:,:,1);
    x.phi2 = sol(:,:,2);
    x.alpha = sol(:,:,3);
    f.F21 = sol(:,:,4);
    f.F22 = sol(:,:,5);
    
end
end

