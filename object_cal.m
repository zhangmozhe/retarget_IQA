function GSV = object_cal(source_image, height_retarget, width_retarget, ...
    pixelIdxList, flow_source, mask_image_source)

seg_num = size(pixelIdxList,1);
height_source = size(source_image, 1);
object_AspectRatio = zeros(seg_num, 1);
object_Size = zeros(seg_num, 1);
object_AspectRatio_transform = zeros(seg_num, 1);
object_Size_transform = zeros(seg_num, 1);
flow_source_x = flow_source(:,:,1);
flow_source_y = flow_source(:,:,2);
epsilon = 0.01;


for object_index = 1: seg_num
    % kickout masked pixels
    temp = uint32(mask_image_source(pixelIdxList{object_index})) .* uint32(pixelIdxList{object_index});
    pixelIdxList{object_index} = double(temp(temp > 0.01));
    
    % find index for the segmented object in the source domain
    x_index = floor(pixelIdxList{object_index} / height_source) + 1;
    y_index = mod(pixelIdxList{object_index}, height_source);
    
    % find index for the segmented object in the retarget domain
    x_index_transform = x_index + flow_source_x(pixelIdxList{object_index});
    y_index_transform = y_index + flow_source_y(pixelIdxList{object_index});
    x_index_transform = index_validate(x_index_transform, 1, width_retarget);
    y_index_transform = index_validate(y_index_transform, 1, height_retarget);
    
    Rw0 = max(x_index(:)) - min(x_index(:));
    Rh0 = max(y_index(:)) - min(y_index(:));
    Rw0_transform = max(x_index_transform(:)) - min(x_index_transform(:));
    Rh0_transform = max(y_index_transform(:)) - min(y_index_transform(:));
    if (isempty(Rw0) || isempty(Rh0) || isempty(Rw0_transform) || isempty(Rh0_transform) ...
            ||Rw0 == 0 || Rh0 == 0 || Rw0_transform ==0 || Rh0_transform == 0)
        object_AspectRatio(object_index) = 1;
        object_Size(object_index) = 1;
        object_AspectRatio_transform(object_index) = 1;
        object_Size_transform(object_index) = 1;
    else
        object_AspectRatio(object_index) = Rw0 / Rh0;
        object_Size(object_index) = Rw0 * Rw0;
        object_AspectRatio_transform(object_index) = Rw0_transform / Rh0_transform;
        object_Size_transform(object_index) = Rw0_transform * Rw0_transform;
    end
end

if seg_num == 0
    GSV = 1;
else
    GSV = (2 * object_AspectRatio .* object_AspectRatio_transform + epsilon)   ...
        ./ (object_AspectRatio .* object_AspectRatio + object_AspectRatio_transform .* object_AspectRatio_transform + epsilon) ...
        .* (2 * object_Size .* object_Size_transform + epsilon) ...
        ./ (object_Size .* object_Size + object_Size_transform .* object_Size_transform + epsilon);
    GSV = sum(GSV .* object_Size + epsilon) / sum(object_Size + epsilon);
end