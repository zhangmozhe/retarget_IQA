function [mean_tau, std_tau, p_value] = main(param)

if nargin < 1
    clc;clear;
    % parameters
    param.k1 = 38;      % local angular similarity: larger-> more sensitive to angular difference
    param.k2 = 5.7;     % larger-> decrease the edge strength attenuation effect
    param.k_edge = 100;
    param.k3 = 1200;    % local tps slope: amplify the tps scale
    param.k4 = 0;       % for confidence map: smaller->more attenuation effect
    param.gamma1 = 2.2; % gamma of relative local aspect ratio
    param.gamma2 = 2;   % gamma of absolute local aspect ratio
    param.IS_offset = 0.65; % information curve offset
    param.IS_slope = 10;    % information curve slope
    param.w0 = 10;      % block width
    param.h0 = 10;      % block height
end

sub = load('data\subjData-ref');
IMAGE_NUM = 37; % 37 sets of images
OPERATOR_NUM = 8;
operator_id = {'cr', 'sv', 'multiop', 'sc', 'scl', 'sm', 'sns', 'warp'};

% file_dir = 'F:\retargetme\retargetme\';
file_dir = '.\retargetme_data\';
dir_list = read_list([file_dir, 'dir.txt']);
filename_list = read_list([file_dir, 'retarget.txt']);
source_list = read_list([file_dir, 'source.txt']);
source_names = read_list([file_dir, 'source_names.txt']);
retarget_list = read_list([file_dir, 'retarget.txt']);

%% get the objective assessments
values = zeros(IMAGE_NUM, OPERATOR_NUM);
LSV = zeros(IMAGE_NUM, OPERATOR_NUM);
info_coefficient = zeros(IMAGE_NUM, OPERATOR_NUM);

for i = 1: IMAGE_NUM
    name = sub.subjData.datasetNames{i};
    name_split = strsplit(name,'_');
    source_name = [];
    for k = 1: size(name_split, 2) - 1
        temp = name_split(k);
        source_name = [source_name, temp{1}, '_'];
    end
    source_name = source_name(1:end-1);
    segmentation_data = load([file_dir, '_segment_output\', source_name, '.png.mat']);
    retarget_ratio = name_split(end);retarget_ratio = retarget_ratio{1};
    
    for j = 3: OPERATOR_NUM
        retarget_name = [source_name,'_',retarget_ratio,'_',operator_id{j}];
        disp(['processing image ', retarget_name]);
        image_index = find_index(retarget_list, [retarget_name,'.png']);
        [values(i,j), LSV(i,j), info_coefficient(i,j)] = ...
            retargeting_assessment(image_index, file_dir, dir_list, ...
            filename_list, source_list, source_names, segmentation_data, param);    
    end
end

%% calculate the kendall rank
sub_data = sub.subjData.data';
obj_data = values';

tau = zeros(IMAGE_NUM, 1);
for i = 1: IMAGE_NUM %loop for sets
    tau(i) = getKLCorr_similarity(sub_data(:,i)', obj_data(:,i)'); % calculate the tao for each set
end
mean_tau = mean(tau);
std_tau = std(tau);
pd = makedist('Normal','mu',0,'sigma',0.2887);
[~, p_value] = chi2gof(tau,'CDF',pd);

if nargin < 1
    mean_tau
    std_tau
    p_value
    save('data\MyData_processing');
end


