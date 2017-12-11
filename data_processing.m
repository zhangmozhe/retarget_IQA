obj = load('.\data\objData');
sub = load('.\data\subjData-ref');

% sub: {datasetNames:37*1, data:37*8}
% obj: 8 method: {datasetNames:37*1, data:37*8}
IMAGE_NUM = 37; % 37 sets of images

sub_data = sub.subjData.data';
obj_data = obj.objData_BDS.data';

RHO = zeros(IMAGE_NUM, 1);
PVAL = zeros(IMAGE_NUM, 1);
for i = 1: IMAGE_NUM %loop for sets
RHO(i) = getKLCorr(sub_data(:,i)', obj_data(:,i)'); % calculate the tao for each set
end
mean_tao = mean(RHO)
std_tao = std(RHO)
pd = makedist('Normal','mu',0,'sigma',0.2887);
[~, p_value] = chi2gof(RHO,'CDF',pd);
p_value