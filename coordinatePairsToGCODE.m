function [gcode_char_combined, target_steps_cell] = coordinatePairsToGCODE(target_points_cell, varargin)
%Outputs formatted GCODE as string; Takes nx2 array of coordinates
%   Output should look the same as if plot() was used
load boundaryResults.mat boundaryObject
load Lookups.mat invLookupObject
load plant_specs.mat funcs

p = inputParser;
addParameter(p, 'plotPath', false);
addParameter(p, 'lineCommand', 0);
addParameter(p, 'assertBoundary', true);
addParameter(p, 'accelControl', true);
parse(p,varargin{:});

gcode_char_cell = cell(size(target_points_cell));
target_steps_cell = cell(size(target_points_cell));

if p.Results.plotPath
    boundaryObject.plotBoundary();
    hold on;
    title('Target Path');
    cellfun(@(c) plot(c(:,1), c(:,2), '-k'), target_points_cell);
    hold off;
end

target_points_cell = cellfun(@removeDuplicates, target_points_cell, 'UniformOutput', false);

for j = 1:length(target_points_cell)
    [gcode_char, target_steps] = main(target_points_cell{j});
    gcode_char_cell{j} = gcode_char;
    target_steps_cell{j} = target_steps;
end

gcode_char_combined = vertcat(gcode_char_cell{:});

    function array = removeDuplicates(array)
        % Remove duplicates from target_points
        r = diff(array);
        r_norm = sqrt(sum(r.^2,2));
        array(r_norm==0, :) = [];
    end


    function [gcode_char, target_steps] = main(target_points)
        target_steps = zeros(size(target_points));
        gcode_char = cell(length(target_points),1);

        if p.Results.accelControl
            r = diff(target_points);
            r_hat = r./repmat(sqrt(sum(r.^2,2)),1,2);
            d = dot(r_hat(1:end-1, :), r_hat(2:end, :), 2);
            d = [-1;d;-1];
            d = round(d.*100);
        end

        for i=1:length(target_points)
            t_p = target_points(i,:);
            disp("Target Point: "+t_p)
            if p.Results.assertBoundary
                assert(boundaryObject.isInBoundary(t_p),'Target point not in boundary');
            end
            t_l = [invLookupObject.inv_kine_lookup.l1(t_p), invLookupObject.inv_kine_lookup.l2(t_p)];
            t_s = funcs.tfLengthsToSteps(t_l);
            target_steps(i,:) = t_s;

            if (i==1)
                pen_pos = 0;
            else
                pen_pos = 1;
            end

            gcode_cmd = sprintf('G0%d L%d R%d Z%d D%d;', p.Results.lineCommand, t_s(1), t_s(2), pen_pos, d(i));
            disp(gcode_cmd)

            gcode_char{i} = gcode_cmd;
        end
    end

end

