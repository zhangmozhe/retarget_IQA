function tps_map = TPS(flow_x, flow_y)
    tpx_map_x = TPS_x(flow_x);
    tpx_map_y = TPS_y(flow_y);
    tps_map = tpx_map_x + tpx_map_y;
end

function TPS_map_x = TPS_x(flow_x)
    TPS_map_x = flow_dxx(flow_x).^2 ...
        + flow_dyy(flow_x).^2 ...
        + 2 * flow_dxy(flow_x).^2;
end

function TPS_map_y = TPS_y(flow_y)
    TPS_map_y = flow_dxx(flow_y).^2 ...
        + flow_dyy(flow_y).^2 ...
        + 2 * flow_dxy(flow_y).^2;
end

function dxx = flow_dxx(flow)
    flow_pad = padarray(flow, [0, 1], 'replicate', 'both');
    dxx = -flow_pad(:,1:end-2) + 2*flow_pad(:, 2:end-1) - flow_pad(:,3:end);
end

function dyy = flow_dyy(flow)
    flow_pad = padarray(flow, [1, 0], 'replicate', 'both');
    dyy = -flow_pad(1:end-2,:) + 2*flow_pad(2:end-1,:) - flow_pad(3:end,:);
end

function dxy = flow_dxy(flow)
    flow_pad = padarray(flow, [1, 1], 'replicate', 'post');
    dx = -flow_pad(:,1:end-1) + flow_pad(:,2:end);
    dxy = -dx(1:end-1,:) + dx(2:end,:);
end
