%%Init
% clear;

u = symunit;
num = @(sym) double(separateUnits(sym));

%%Plant Specs
g = 9.81; %m/s^2
scribit_mass = 1.1; %kg

masses = struct(); %kg %Masses need updated once scale arrives - Up to date with model
masses.motor_left = 0.2;
masses.motor_right = 0.2;
masses.servo = 20e-3;
masses.other = num(unitConvert(0.8641*u.lbm,u.kg));

%approx_mass = sum(cell2mat(struct2cell(masses)));
approx_mass = 0.973;

%Friction coefficients - depricated
% bearing.mu = 0.002;
% bearing.OD = num(unitConvert(0.05*u.in,u.m)); %m
% bearing.BD = 0.0;
% bearing.PD = mean([bearing.OD bearing.BD]);

syms theta
% bearing.r1 = bearing.OD*[1 0 0];
% bearing.alpha = 2*pi-(pi/2+pi/2+(pi-theta));
% bearing.r2 = bearing.OD*[cos(bearing.alpha) sin(bearing.alpha) 0];

motor.max_holding_torque = 0.23; %N*m
motor.microstep_resolution = 8;
motor.step_resolution = deg2rad(1.8)/motor.microstep_resolution;

%% Unknown Sym Vars
syms l1 l2 positive real;
syms px py real;
syms phi1 phi2 alpha real;
syms F21 F22 positive real ;

%% Geometry
dims.w = num(unitConvert(mean([6.72,6.62])*u.in, u.m)); % System width - Updated
dims.r1 = [-(dims.w)/2 num(unitConvert(mean([2.09,2.04])*u.in,u.m)) 0]';% COM to Left Tangent Point - Updated
dims.r2 = [(dims.w)/2 num(unitConvert(mean([2.09,2.04])*u.in,u.m)) 0]';% COM to Right Tangent Point - Updated
dims.rp = [0 num(unitConvert(2.09*u.in,u.m)) 0]'; %Pen Height from COM - Updated
dims.W = num(unitConvert(54.25*u.in, u.m)); %Pin Width - Updated
dims.WSurface = num(unitConvert(54.75*u.in, u.m)); %Width of drawing surface
dims.WPaper = num(unitConvert(11*u.in, u.m)); % Witdh of Paper on Drawing Surface
dims.H = num(unitConvert(54*u.in, u.m)); %Overall Height - Updated
dims.HSurface = num(unitConvert(23.25*u.in, u.m)); %Height of drawing surface
dims.HPaper = num(unitConvert(8.5*u.in, u.m));%dims.HSurface; % Height of paper on drawing surface
dims.rGlobalToSurface = num(unitConvert([-.25 -18.5]*u.in, u.m)); %Vector from Global origin to Surface origin in Global frame
dims.rSurfaceToPaper = num(unitConvert([22.5 -5.25]*u.in, u.m));
dims.stringLengths = num(unitConvert([45.25, 44.5+1/8]*u.in, u.m));
dims.rl1 = [cos(phi1) -sin(phi1) 0]';
dims.rl2 = [-cos(phi2) -sin(phi2) 0]';
dims.Rz = [cos(alpha) -sin(alpha) 0; sin(alpha) cos(alpha) 0; 0 0 1];
dims.C = num(unitConvert(1.86*u.in, u.m)); % pully Circumference, minimum string path - Updated
dims.D = num(unitConvert(0.6*u.in,u.m)); %pulley diameter - nominal

dims.maxStringLength = min(dims.stringLengths); % Maximally extended length of L1 and L2 - Updated
%% Functions
funcs.pulleyTorque = @(f) (dims.D)/2.*f;
funcs.tfLengthsToSteps = @(l) round((dims.maxStringLength-l)./(0.5*dims.D*motor.step_resolution));
funcs.tfLengthsToStepsDelta = @(delta_l) round(-delta_l./(0.5*dims.D*motor.step_resolution));
funcs.tfStepsToLengths = @(s) -s*(0.5*dims.D*motor.step_resolution)+dims.maxStringLength;
funcs.tfStepsToLengthsDelta = @(delta_s) -delta_s*(0.5*dims.D*motor.step_resolution);
funcs.tfGlobalToSurface = @(p_global) p_global - dims.rGlobalToSurface; %Transforms point in global frame to point in surface frame
funcs.tfSurfaceToGlobal = @(p_surface) p_surface + dims.rGlobalToSurface; %Transforms point in surface frame to point in global frame
funcs.tfGlobalToPaper = @(p_global) p_global - dims.rGlobalToSurface - dims.rSurfaceToPaper; %Transforms point in global frame to point in surface frame
funcs.tfPaperToGlobal = @(p_surface) p_surface + dims.rGlobalToSurface + dims.rSurfaceToPaper; %Transforms point in surface frame to point in global frame
%% Calculated Constants
dims.stringTrimsSteps = funcs.tfLengthsToStepsDelta(dims.maxStringLength - dims.stringLengths );

%% Equations
eqns = struct();

%eq1 = sum forces
eqns.eq1 = F21*(-dims.rl1)+F22*(-dims.rl2)+[0 -approx_mass*g 0]' == [0 0 0]';
eqns.eq1 = vpa(eqns.eq1(1:2));

%eq2 = sum moment
eqns.eq2 = cross(dims.Rz*dims.r1, F21*(-dims.rl1))+cross(dims.Rz*dims.r2, F22*(-dims.rl2))==[0 0 0]';
eqns.eq2 = vpa(eqns.eq2(3));

%eq3 = closed geo chain
eqns.eq3 = l1*dims.rl1+dims.Rz*(-dims.r1)-([dims.W 0 0]'+l2*dims.rl2+dims.Rz*(-dims.r2))==[0 0 0]';
eqns.eq3 = vpa(eqns.eq3(1:2));

%eq4 = inv kine
eqns.eq4 = l1*dims.rl1+dims.Rz*(-dims.r1+dims.rp)-[px py 0]' == [0 0 0]';
eqns.eq4 = vpa(eqns.eq4(1:2));


%% Forward Kine
fwdKineSys = struct();
fwdKineSys.vars = {[l1 l2], [px py phi1 phi2 alpha F21 F22]};
fwdKineSys.eqns_sym = lhs([eqns.eq1;eqns.eq2;eqns.eq3;eqns.eq4]);
fwdKineSys.eqns_mat = matlabFunction(fwdKineSys.eqns_sym, 'vars', fwdKineSys.vars);
fwdKineSys.dims.W = dims.W;

%x = [x y phi1 phi2 alpha]; init calculated from standard polargraph equations
fwdKineSys.ub.x = [dims.W, 0, deg2rad([90 90 90])];
fwdKineSys.lb.x = [0, -dims.H, deg2rad([0 0 -90])];

%f = [F21 F22]
fwdKineSys.approx_weight = approx_mass*g;
fwdKineSys.x0.f = approx_mass*g/2*[1 1];
fwdKineSys.ub.f = [inf inf];
fwdKineSys.lb.f = [0 0];

%% Inv Kine
% Inherits from Fwd Kine
invKineSys = fwdKineSys;

invKineSys.vars = {[px py], [l1 l2 phi1 phi2 alpha F21 F22]};
invKineSys.eqns_sym = lhs([eqns.eq1;eqns.eq2;eqns.eq3;eqns.eq4]);
invKineSys.eqns_mat = matlabFunction(invKineSys.eqns_sym, 'vars', invKineSys.vars);

%l = [l1 l2]; init calculated from polargraph equations
invKineSys.maxStringLength = dims.maxStringLength;
invKineSys.ub.x = [norm([dims.W dims.H])*[1 1] fwdKineSys.ub.x(3:end)]; %Allow solver to go all the way to max length in grid.  Not sure how to have it error out if length exceeded, to output is modified if l exceends maxStringLength
invKineSys.lb.x = [[0 0] fwdKineSys.lb.x(3:end)];

%% Save to MAT
save("plant_specs.mat");

