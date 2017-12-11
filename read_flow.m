function [flow, flow_color] = read_flow(filename)
figure_show = 0 ;
if nargin < 1
    clear;
    figure_show = 1;
    filename = 'C:\Users\Bo\Desktop\resized\retargetme\ArtRoom\flow_overall\ArtRoom_0.75_cr.png.txt';
end

flow_data = flow_read(filename);
width = max(flow_data.x) + 1;
height = max(flow_data.y) + 1;
flow = zeros(height, width, 2);

flow_x = flow_data.dx;
flow_y = flow_data.dy;
flow_x_tmp = reshape(flow_x, [width, height]);
flow_y_tmp = reshape(flow_y, [width, height]);
flow_x = flow_x_tmp';
flow_y = flow_y_tmp';

flow(:,:,1) = flow_x;
flow(:,:,2) = flow_y;

if nargout > 1
    flow_color = flowToColor(flow);
end
if figure_show == 1
    figure;imshow(flow_color)
end

