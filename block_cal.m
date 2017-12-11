function [LSV, blocks, alpha_array, LAR_array, LED_array] = ...
    block_cal(source_image, mask_image_source, flow_image_source, SED_edge,...
    SED_direction, saliency_map, TPS, ssimmap, ssimmap_lum, param)
% initialization: k1=20; k2=6; k3=1000; k4=1; gamma1=8; gamma2=1;
% k1 = param.k1;
% k2 = param.k2;
k_edge = param.k_edge;
k3 = param.k3;
k4 = param.k4;
gamma1 = param.gamma1; 
gamma2 = param.gamma2;
w0 = param.w0;
h0 = param.h0;
epsilon = 0.01;
block.w = 0;
block.h = 0;
block.alpha = 0; % absolute aspect ratio: w/h
block.mask = 1;
block.angle_similarity = 0;
block.principal_angle1 = 0;
block.principal_angle2 = 0;
block.angle_similarity_weighted = 0;
block.saliency = 0;

height_source = size(source_image, 1);
width_source = size(source_image, 2);
N_h = floor(height_source/h0);
N_w = floor(width_source/w0);
blocks = repmat(block, [N_h, N_w]);
alpha_array = zeros(N_h, N_w);
angle_similarity_array = zeros(N_h, N_w);
LED_array = zeros(N_h, N_w); % local edge direction
LAR_array = zeros(N_h, N_w); % local aspect ratio
saliency_array = zeros(N_h, N_w);
mask_array = zeros(N_h, N_w);
TPS_array = zeros(N_h, N_w);
confidence_array = zeros(N_h, N_w);
confidence_array_lum = zeros(N_h, N_w);
[x_grid, y_grid] = meshgrid(1:w0, 1:h0);
block_size = w0 * h0;

for i = 1: N_w
    for j = 1: N_h
        x_index = ((i-1)*w0 + 1): i*w0;
        y_index = ((j-1)*h0 + 1): j*h0;
        
        % local aspect ratio (LAR)
        x_index_transform = x_grid + flow_image_source(y_index, x_index, 1); % transformed in retarget domain
        y_index_transform = y_grid + flow_image_source(y_index, x_index, 2); % transformed in retarget domain
        x_range_transform = [min(x_index_transform(:)), max(x_index_transform(:))];
        y_range_transform = [min(y_index_transform(:)), max(y_index_transform(:))];
        blocks(j, i).w = x_range_transform(2) - x_range_transform(1);
        blocks(j, i).h = y_range_transform(2) - y_range_transform(1);
        blocks(j, i).alpha = blocks(j, i).w / blocks(j, i).h;
        alpha_array(j, i) = blocks(j, i).alpha;
        Rw = blocks(j, i).w / w0;
        Rh = blocks(j, i).h / h0;
        S0 = block_size;
        S1 = blocks(j, i).w * blocks(j, i).h;
        LAR_array(j, i) = ( (2*Rw*Rh + epsilon)/(Rw*Rw + Rh*Rh + epsilon) )^gamma1 ...
            * ( (2*S0*S1 + epsilon)/(S0*S0 + S1*S1 + epsilon) )^gamma2;       
        
        % mask and saliency
        mask_values = mask_image_source(y_index, x_index);
        if sum(mask_values == 0)
            blocks(j, i).mask = 0;
        end
        mask_array(j, i) = blocks(j, i).mask;
        saliency_values = saliency_map(y_index, x_index);
        blocks(j ,i).saliency = sum(saliency_values(:)); 
        saliency_array(j, i) = blocks(j ,i).saliency;
        
        % local edge direction (LED)
        edge_strengths = SED_edge(y_index, x_index);
        edge_angles = SED_direction(y_index, x_index);
        principal_angle1 = sum(sum(edge_strengths.*edge_angles) + epsilon) / (sum(edge_strengths(:)) + epsilon);
        principal_angle2 = atan( tan(principal_angle1) / blocks(j, i).alpha );
        if principal_angle2 < 0 % atan range from [-pi/2, pi/2], needs rescale
            principal_angle2 = principal_angle2 + pi;
        end
        blocks(j, i).principal_angle1 = principal_angle1;
        blocks(j, i).principal_angle2 = principal_angle2;
        blocks(j, i).angle_similarity = exp(- (principal_angle1 - principal_angle2).^2); %blocks(j, i).angle_similarity = cos(principal_angle1 - principal_angle2)^2;
        angle_similarity_array(j, i) = blocks(j, i).angle_similarity;
        blocks(j, i).edge_strength = sum(edge_strengths(:)) / block_size;
        blocks(j, i).angle_similarity_weighted = (blocks(j, i).angle_similarity) ...
            ^ ( (blocks(j, i).edge_strength * k_edge) );
        LED_array(j, i) = blocks(j, i).angle_similarity_weighted;
        
        % tps map
        TPS_values = TPS(y_index, x_index);
        tps_average = sum(TPS_values(:)) / block_size;
        TPS_array(j, i) = exp(-k3 * tps_average);
        
        % confidence map
        ssimval_block = ssimmap(y_index, x_index);
        confidence_array(j, i) = sum(ssimval_block(:)) / block_size; %% ssim
        ssimval_block_lum = ssimmap_lum(y_index, x_index);
        confidence_array_lum(j, i) = sum(ssimval_block_lum(:)) / block_size; %% ssim's luminance part
    end
end
TPS_array(TPS_array < 0.25) = 1;

% LSV = sum(sum(  ((LED_array .*LAR_array .*TPS_array).^(confidence_array * k4)) .*saliency_array.*mask_array  ))...
%     / sum(sum( saliency_array.*mask_array ));
% LSV = sum(sum(  ((LED_array .*LAR_array .*TPS_array .*confidence_array)).^confidence_array_lum .*saliency_array.*mask_array  ))...
%     / sum(sum( saliency_array.*mask_array ));
LSV = sum(sum(  ((LED_array .*LAR_array .*TPS_array .*confidence_array)).^confidence_array_lum .*saliency_array .*mask_array  ))...
    / sum(sum( saliency_array.*mask_array ));


% figure;imshow(alpha_array);title('aspect ratio map for blocks');
% figure;imshow(saliency_array, []);title('saliency map for blocks');
% figure;imshow(LAR_array);title('Aspect ratio similarity map');
% figure;imshow(LED_array);title('angle similarity weighted');
% figure;imshow(TPS_array);title('TPS similairty map');
% figure;imshow(mask_array);title('mask map');
% figure;imshow(((LED_array .*LAR_array .*TPS_array).^(confidence_array * k4)));title('combined local similarity')


