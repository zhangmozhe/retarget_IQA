clear; clc
for computation_index = 1:600 % loop for 100
%     param.k1 = rand(1)*(100 - 25) + 25;  % local angular similarity: larger->more sensitive to angular difference
%     param.k2 = rand(1)*(8 - 2.0) + 2.0;   % larger->decrease the edge strength attenuation effect
    param.k_edge = 100;  % local angular simialirity coefficient
    param.k3 = 1200;  % local tps slope: amplify the tps scale
    param.k4 = 0;  % for confidence map: smaller->more attenuation effect
    param.gamma1 = rand(1)*(5 - 1.8) + 1.8; % gamma of relative local aspect ratio
    param.gamma2 = rand(1)*(2.5 - 1.0) + 1.0; % gamma of absolute local aspect ratio
    param.IS_offset = rand(1)*(0.8 - 0.4) + 0.4;% information curve offset
    param.IS_slope = rand(1)*(12 - 6) + 6;  % information curve slope
    param.w0 = 10; % block width
    param.h0 = param.w0; % block height
    
    [tau, tau_std, p_value] = MyData_processing(param);
    
    result_temp.tau = tau;
    result_temp.tau_std = tau_std;
    result_temp.p_value = p_value;
    result_temp.param = param;
    if ~exist('result')
        result = result_temp;
    else
        result = [result, result_temp];
    end
    save ('data\MonteCarlo_result', 'result', 'computation_index');
    
    [computation_index, result_temp.tau]
    param
end

