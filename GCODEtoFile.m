function GCODEtoFile(gcode_char_cell,path)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
writecell(gcode_char_cell, path);
disp("Finished Writing To: "+path);
end

