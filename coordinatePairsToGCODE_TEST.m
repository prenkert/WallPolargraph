close all;

%Simple Square:
% coord_pairs = funcs.tfPaperToGlobal([dims.WPaper/2,-dims.HPaper/2]+.03.*[-1, 1; 1, 1; 1, -1; -1, -1; -1, 1]);

%Virginia V: 
%coord_pairs = loadsvg('Virginia_Cavaliers_sabre.svg', .25, true);

%Abstract Lines:
% coord_pairs = loadsvg('AbstractLines.svg', .75, true);

%House Blueprint:
coord_pairs = loadsvg('Blueprint_2.svg', .5, true);

coord_pairs = cellfun(@(c) [c(:,1) -c(:,2)], coord_pairs, 'UniformOutput', false);
coord_pairs_list = vertcat(coord_pairs{:});
vector_size = max(coord_pairs_list)-min(coord_pairs_list);
[size_max, i_max] = max(vector_size);
scale_factor = 0.2/size_max; % scale to 20 cm in largest dimension
coord_pairs = cellfun(@(c) (c - mean(coord_pairs_list))*scale_factor+funcs.tfPaperToGlobal([dims.WPaper/2, -dims.HPaper/2]), coord_pairs, 'UniformOutput', false); %Centerscale to desired size



[gcode_char, target_steps] = coordinatePairsToGCODE(coord_pairs, 'plotPath', true, 'lineCommand', 0, 'assertBoundary', true);
GCODEtoFile(gcode_char, 'GCODE\TEST.txt')