function [value_assessment, LSV, information_coeff] = ...
    retargeting_assessment(image_index, file_dir, dir_list, filename_list, ...
    source_list, source_names, segmentation_data, param)

if nargin < 1
    image_index = 2;
    file_dir = '..\retargetme\';
    dir_list = read_list([file_dir, 'dir.txt']);
    filename_list = read_list([file_dir, 'retarget.txt']);
    source_list = read_list([file_dir, 'source.txt']);
    source_names = read_list([file_dir, 'source_names.txt']);
    % parameters
    param.k1 = 38;  % local angular similarity: larger-> more sensitive to angular difference
    param.k2 = 5.7;   % larger-> decrease the edge strength attenuation effect
    param.k_edge = 200;
    param.k3 = 1000;% local tps slope: amplify the tps scale
    param.k4 = 1;   % for confidence map: smaller->more attenuation effect
    param.gamma1 = 3; % gamma of relative local aspect ratio
    param.gamma2 = 1; % gamma of absolute local aspect ratio
    param.IS_offset = 0.5;% information curve offset
    param.IS_slope = 10;  % information curve slope
    param.w0 = 8; % block width
    param.h0 = 8; % block height
end

figure_show = 1; warning('off', 'Images:initSize:adjustingMag');
console_output = 0;

% image number
image_total = size(filename_list,1);
source_total = 80;

% filenames
retarget_name = filename_list{image_index};
source_resize_name = source_list{image_index};
source_name = dir_list{image_index};
flow_file = [file_dir, source_name, '\flow_overall\', retarget_name, '.txt'];

% read source, retarget, mask, re-aligned, saliency, SED edge
source_image = imread([file_dir, '_source\', source_name, '.png']);
source_resized_image = imread([file_dir, '_resized_source\', source_resize_name]);
retarget_image = imread([file_dir, source_name, '\', retarget_name]);
aligned_image = imread([file_dir, source_name, '\optimization_overall\', retarget_name]);
saliency_map = imread([file_dir, '_saliency_new\saliency_blend\', source_name, '.png']);
mask_image_resized = GetMask(aligned_image);
[segmentation_map, pixelIdxList, ~, segmentation_num] = read_segmentation_data(segmentation_data, source_image);
[SED_edge, SED_direction] = read_SED(file_dir, source_names, source_name);

% retarget information
retarget_name_split = strsplit(retarget_name,'_');
retarget_ratio = retarget_name_split(end-1);
retarget_ratio = retarget_ratio{1};
retarget_ratio = str2double(retarget_ratio);
retarget_method = retarget_name_split(end);retarget_method = retarget_method{1};retarget_method = strsplit(retarget_method, '.');
retarget_method = retarget_method{1}; %#ok
height_source = size(source_image, 1);
width_source = size(source_image, 2);
height_retarget = size(retarget_image, 1);
width_retarget = size(retarget_image, 2);
if width_source/height_source > width_retarget/height_retarget
    retarget_orientation = 1; % horizontal scaling
else
    retarget_orientation = 2; % vertical scaling
end
if size(retarget_image) ~= size(source_image)
    retarget_image = imresize(retarget_image, size(source_image));
    disp('The size of the retargeted image has been resized');
end

% read flow
[flow] = read_flow(flow_file); % can output flow_color
flow_x = flow(:,:,1);
flow_y = flow(:,:,2);
[flow_source] = flow_transform(flow, retarget_orientation, retarget_ratio, width_source, height_source);
flow_source_x = flow_source(:,:,1);
flow_source_y = flow_source(:,:,2);

% figure show
if figure_show == 1
%     figure;imshow(flow_color);title('flow color on the resized domain');
%     figure;imshow(flow_source_color);title('flow color on the source domain');
    figure;imshow(source_image);title('source image on the source image');
    figure;imshow(source_resized_image);title('source image on the resized domain');
    figure;imshow(retarget_image);title('retargeted image on the retarget domain');
    figure;imshow(saliency_map);title('BMS saliency on the source domain');
    figure;imshow(aligned_image);title('aligned image on the resized domain');
    figure;imshow(mask_image_resized);title('mask on the resized domain');
%     figure;imshow(image_segment);title('image segmentation on the source domain');
    figure;imshow(SED_edge);title('Strutured edge on the source domain');
end

% sets correspondence among source, retarget, mask, and flow
realigned_image = back_registration(source_image, retarget_image, flow_x, flow_y, retarget_orientation, retarget_ratio);
if figure_show == 1
    figure;imshow(realigned_image);title('re-aligned image on the source domain');
end
mask_image_source = imresize(mask_image_resized, [height_source, width_source]);


%% local similarity
[~, ssimmap] = ssim(rgb2gray(source_image), rgb2gray(realigned_image));
[~, ssimmap_lum] = ssim(rgb2gray(source_image), rgb2gray(realigned_image), 'Exponents', [1 0 0]);

% tps on the source domain
tps_map_source = TPS(flow_source_x, flow_source_y);

% divide the source image into small blocks; calculate angular & aspect
% raio similarity; pool the aspect raio map, angular map, tps map with
% saliency map & mask get the local similaity value;
LSV = block_cal(source_image, mask_image_source, flow_source, SED_edge, SED_direction, ...
    saliency_map, tps_map_source, ssimmap, ssimmap_lum, param);

if figure_show == 1
    figure;imshow(ssimmap);title('ssimmap on the source domain');
    figure;imshow(tps_map_source * 2000); title('TPS source map');
end

%% global similarity
GSV = object_cal(source_image, height_retarget, width_retarget, pixelIdxList, ...
    flow_source, mask_image_source);

%% information preservation on the source
% area_image = height_source * width_source;
% area_mask = sum(sum(mask_image_source));
% information_percentage_physical = area_mask / area_image;
area_saliency = sum(sum(saliency_map));
BMS_saliency_masked = mask_image_source .* double(saliency_map);
area_mask_saliency = sum(sum(BMS_saliency_masked));
information_percentage_saliency = area_mask_saliency / area_saliency;
information_loss = 1 - information_percentage_saliency;


% combine LSV, GSV, IS
information_coeff = 1 ./ (1 + exp((information_loss-param.IS_offset)*param.IS_slope));
value_assessment = information_coeff * LSV * GSV;

if isnan(value_assessment)
    warning([retarget_name,' ouputs NaN!!!!!']);
    LSV = 1;
    value_assessment=1;
end

%% console output
if console_output == 1
    disp(['LSV=', num2str(LSV)]);
    disp(['information_coeff=', num2str(information_coeff)]);
    disp(['value_assessment=', num2str(value_assessment)]);
end

value_assessment = real(value_assessment);
LSV=real(LSV);
information_coeff = real(information_coeff);
