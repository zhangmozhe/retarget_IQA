function [flow_source, flow_source_color] = flow_transform(flow, retarget_orientation, retarget_ratio, width_source, height_source)
% transform the flow from the resized domain to the source domain
height_flow = size(flow, 1);
width_flow = size(flow, 2);
alpha = retarget_ratio;

flow_source = zeros(height_source, width_source, 2);
[x_flow_grid, y_flow_grid] = meshgrid(1: width_flow, 1: height_flow);
[x_source_grid, y_source_grid] = meshgrid(1: width_source, 1: height_source);

if retarget_orientation == 1
    flow_source(:,:,1) = interp2(x_flow_grid, y_flow_grid, double(flow(:,:,1)), x_source_grid*alpha, y_source_grid) - (1-alpha)*x_source_grid;
    flow_source(:,:,2) = interp2(x_flow_grid, y_flow_grid, double(flow(:,:,2)), x_source_grid*alpha, y_source_grid);
    flow_source_temp = flow_source(:,2:end,:);
    flow_source = padarray(flow_source_temp, [0,1], 'pre','replicate');
else
    flow_source(:,:,1) = interp2(x_flow_grid, y_flow_grid, double(flow(:,:,1)), x_source_grid, y_source_grid*alpha);
    flow_source(:,:,2) = interp2(x_flow_grid, y_flow_grid, double(flow(:,:,2)), x_source_grid, y_source_grid*alpha) - (1-alpha)*y_source_grid;
    flow_source_temp = flow_source(2:end,:,:);
    flow_source = padarray(flow_source_temp, [1,0], 'pre','replicate');
end

if nargout > 1
    flow_source_color = flowToColor(flow_source);
end

