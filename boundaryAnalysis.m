    function boundaryObject = boundaryAnalysis(pointsGridObject, invKineObject, varargin)
%Explores possible boundary 
% x_vals and y_vals are lists that will be combined into a   
% invKineOutput must be a struct with the following fields:
%   - l: 
%   - f: 

load plant_specs.mat funcs motor dims;

p = inputParser;
addParameter(p,'plotIntermediateFigures', false);
addParameter(p,'plotFinalBoundary', true);
parse(p,varargin{:});

x_min = pointsGridObject.x_min;
x_max = pointsGridObject.x_max;
y_min = pointsGridObject.y_min;
y_max = pointsGridObject.y_max;
x_list = pointsGridObject.x_list;
y_list = pointsGridObject.y_list;
delta = pointsGridObject.delta;

l = invKineObject.l;
f = invKineObject.f;

%% Filter 1 - Torque Safety Factor
minTorqueSF = 3.75;

T = funcs.pulleyTorque(max(f.F21,f.F22));
torqueSafetyFactor = motor.max_holding_torque./T;
masked_TSF = torqueSafetyFactor;
masked_TSF(masked_TSF<minTorqueSF) = NaN;
bin_TSF = torqueSafetyFactor;
bin_TSF(bin_TSF<minTorqueSF) = 0;
bin_TSF(isnan(bin_TSF)) = 0;
bin_TSF(bin_TSF>=minTorqueSF) = 1;

%% Fitler 2 - Min Line Tension
minLineTension = 2;

lineTension = min(f.F21, f.F22);
masked_lineTension = lineTension;
masked_lineTension(masked_lineTension<minLineTension) = NaN;
bin_lineTension = lineTension;
bin_lineTension(bin_lineTension<minLineTension) = 0;
bin_lineTension(isnan(bin_lineTension)) = 0;
bin_lineTension(bin_lineTension>=minLineTension) = 1;

%% Filter 3
%Resolution (delta_p/delta_l) Filter
%Redo This with Forward Kinematics or Think More; Do with simple direct
%equations as a check
max_allowable_dpdstep = 0.005; %1/2 cm

[dl1dx, dl1dy] = gradient(l.l1, delta);
dpdl1 = vecnorm(cat(3,1./dl1dx, 1./dl1dy),2,3);

[dl2dx, dl2dy] = gradient(l.l2, delta);
dpdl2 = vecnorm(cat(3,1./dl2dx, 1./dl2dy),2,3);

max_dpdl = max(dpdl1, dpdl2);
max_dpdstep = max_dpdl*(dims.D/2)*motor.step_resolution;

masked_max_dpdstep = max_dpdstep;
masked_max_dpdstep(masked_max_dpdstep>max_allowable_dpdstep) = NaN;

bin_max_dpdstep = max_dpdstep;
bin_max_dpdstep(max_dpdstep<=max_allowable_dpdstep) = 1;
bin_max_dpdstep(max_dpdstep>max_allowable_dpdstep) = 0;
bin_max_dpdstep(isnan(bin_max_dpdstep)) = 0;

%% Filter 4
% Max Line Length Filter
max_line_length = max(l.l1, l.l2);

masked_max_line_length = max_line_length;
masked_max_line_length(max_line_length>dims.maxStringLength) = NaN;

bin_max_line_length = max_line_length;
bin_max_line_length(max_line_length<=dims.maxStringLength) = 1;
bin_max_line_length(max_line_length>dims.maxStringLength) = 0;
bin_max_line_length(isnan(bin_max_line_length)) = 0;

%% Filter 5
% Plottable Surface Boundary
masked_x_list = x_list;
masked_y_list = y_list;

masked_x_list(x_list<(dims.rGlobalToSurface(1)) | x_list>(dims.rGlobalToSurface(1)+dims.WSurface)) = NaN;
masked_y_list(y_list>(dims.rGlobalToSurface(2)) | x_list<(dims.rGlobalToSurface(2)+dims.HSurface)) = NaN;

bin_x_list = x_list;
bin_y_list = y_list;

bin_x_list(x_list<(dims.rGlobalToSurface(1)) | x_list>(dims.rGlobalToSurface(1)+dims.WSurface)) = 0;
bin_x_list(not(x_list<(dims.rGlobalToSurface(1)) | x_list>(dims.rGlobalToSurface(1)+dims.WSurface))) = 1;
bin_y_list(y_list>(dims.rGlobalToSurface(2)) | x_list<(dims.rGlobalToSurface(2)+dims.HSurface)) = 0;
bin_y_list(not(y_list>(dims.rGlobalToSurface(2)) | x_list<(dims.rGlobalToSurface(2)+dims.HSurface))) = 1;

bin_plottable_surface = bin_y_list & bin_x_list;
%% Intermediate Figures
if p.Results.plotIntermediateFigures
    plotFigure(masked_TSF, bin_TSF, "Torque Safety Factor", "S.F.")
    plotFigure(masked_lineTension, bin_lineTension, "Min Line Tension", "Tension - N")
    plotFigure(masked_max_dpdstep, bin_max_dpdstep, "Min Resolution", "DPDL")
    plotFigure(masked_max_line_length, bin_max_line_length, "Max Line Length", "Line Length - m")
end

%% Combined Boundary
bin_boundary = bin_TSF & bin_lineTension & bin_max_dpdstep & bin_max_line_length & bin_plottable_surface;

poly = bwboundaries(bin_boundary);
poly = poly{:}; % Returns y,x coordinate pairs for some reason
poly = [poly(:,2), poly(:,1)]; % switch to x,y coordinate pairs

img_size = size(bin_boundary);
poly(:,1) = interp1([0 img_size(2)],[x_min x_max], poly(:,1));
poly(:,2) = interp1([0 img_size(1)],[y_min y_max], poly(:,2));

if p.Results.plotFinalBoundary
    plotBoundary()
end

%% Output Results
boundaryObject.bin_boundary = bin_boundary;
boundaryObject.poly = poly;
boundaryObject.isInBoundary = @(p) inpolygon(p(1), p(2), poly(:,1), poly(:,2));
boundaryObject.plotBoundary = @() plotBoundary();

save("boundaryResults.mat", "boundaryObject");

%% - SubFuncs
    function plotFigure(masked_data, bin_data, plot_title, z_label)
        figure;               
        subplot(1,2,1);
        surf(x_list,y_list, masked_data)
        axis([x_min x_max y_min y_max])
        daspect([1 1 10]);
        zlabel(z_label);
        
        subplot(1,2,2);
        contour(x_list,y_list,bin_data)
        axis([x_min x_max y_min y_max], 'equal')
        
        sgtitle(plot_title);
    end

    function plotBoundary()
        figure;
        imshow(bin_boundary, 'XData', [x_min, x_max], 'YData', [y_min, y_max], 'InitialMagnification', 'fit')
        set(gca, 'YDir', 'normal');
        hold on
        axis([x_min x_max y_min y_max]);
        plot(poly(:,1), poly(:,2));
        corners_x = dims.rGlobalToSurface(1)+[0 dims.WSurface dims.WSurface 0 0]; %Defines plottable surface boundary
        corners_y = dims.rGlobalToSurface(2)+[0 0 -dims.HSurface -dims.HSurface 0];
        plot(corners_x, corners_y, '-y');
        paper_corners_global = funcs.tfPaperToGlobal([0,0;dims.WPaper, 0; dims.WPaper, -dims.HPaper; 0, -dims.HPaper; 0,0]);
        plot(paper_corners_global(:,1), paper_corners_global(:,2), '-ro');
        title("Combined Boundary")
        hold off

    end
        


end

