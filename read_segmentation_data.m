function [segmentation_map, pixelIdxList, image_segment, seg_num] = read_segmentation_data(segmentation_data, source_image)
segmentation_map_data = segmentation_data.maps;
% pixelIdxList_data = segmentation_data.pixelIdxList;
% image_segment_data = segmentation_data.image_segment;

height_source = size(source_image, 1);
width_source = size(source_image, 2);
% [height_data, width_data] = size(segmentation_map_data);

segmentation_map = imresize(segmentation_map_data, [height_source, width_source]);
segmentation_map = logical(segmentation_map);
se = strel('disk',5);
segmentation_map = imclose(segmentation_map, se);

L = bwlabel(segmentation_map);
seg_num = max(max(L));
pixelIdxList = cell(seg_num, 1);
for i = 1: seg_num
    pixelIdxList{i} = find(L == i);
end

BW = boundarymask(L); 
image_segment = imoverlay(source_image, BW, [1 0 0]);






