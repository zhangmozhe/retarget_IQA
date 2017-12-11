function realigned_image = back_registration(source_image, retarget_image, flow_x, flow_y, retarget_orientation, retarget_ratio)
height = size(source_image, 1);
width = size(source_image, 2);
[x_source_grid, y_source_grid] = meshgrid(1: width, 1: height);

% find the corrsponding index in the resized domain
if retarget_orientation == 1
    x_source_resized = x_source_grid * retarget_ratio;
    y_source_resized = y_source_grid;
else
    x_source_resized = x_source_grid;
    y_source_resized = y_source_grid * retarget_ratio;
end
x_source_resized = index_validate(x_source_resized, 1, size(flow_x, 2));
y_source_resized = index_validate(y_source_resized, 1, size(flow_y, 1));

% find the corresponding index in the retarget domain 
[x_flow_grid, y_flow_grid] = meshgrid(1: size(flow_x, 2), 1: size(flow_x, 1));
x_retarget = x_source_resized + interp2(x_flow_grid, y_flow_grid, double(flow_x), x_source_resized, y_source_resized);
y_retarget = y_source_resized + interp2(x_flow_grid, y_flow_grid, double(flow_y), x_source_resized, y_source_resized);
x_retarget = index_validate(x_retarget, 1, size(retarget_image, 2));
y_retarget = index_validate(y_retarget, 1, size(retarget_image, 1));

% get the value using the index in the retarget domain
[x_retarget_grid, y_retarget_grid] = meshgrid(1: size(retarget_image, 2), 1: size(retarget_image, 1));
realigned_image = zeros(size(source_image));
realigned_image(:,:,1) = interp2(x_retarget_grid, y_retarget_grid, double(retarget_image(:,:,1)), x_retarget, y_retarget);
realigned_image(:,:,2) = interp2(x_retarget_grid, y_retarget_grid, double(retarget_image(:,:,2)), x_retarget, y_retarget);
realigned_image(:,:,3) = interp2(x_retarget_grid, y_retarget_grid, double(retarget_image(:,:,3)), x_retarget, y_retarget);
realigned_image = uint8(realigned_image);
end

function x = index_validate(x, lowerlimit, upperlimit)
x(x < lowerlimit) = lowerlimit;
x(x > upperlimit) = upperlimit;
end
