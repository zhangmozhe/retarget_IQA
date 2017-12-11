function [SED_edge, SED_direction] = read_SED(file_dir, source_names, source_name)
% SED = load([file_dir, '_segment_output\', num2str(FindIndex(source_names, source_name)), '_SED.mat']);
SED = load([file_dir, '_segment_output\', source_name, '.png_SED.mat']);
SED_edge = SED.E;
SED_direction = SED.O;

SED_direction = SED_direction - pi/2; % normal direction to edge direction
SED_direction(SED_direction >= pi) = SED_direction(SED_direction >= pi) - pi;
SED_direction(SED_direction < 0) = SED_direction(SED_direction < 0) + pi;

