function [slope, time2] = slope_compute(data_for_slope,time,  num_spl)
%SLOPE_COMPUTE Summary of this function goes here
%   Detailed explanation goes here
slope = [];
for i = num_spl:length(data_for_slope)
    c = polyfit(time((i+1-num_spl):i), data_for_slope((i+1-num_spl):i), 1);
    slope = [slope c(1)];
end
time2 = time(num_spl:length(data_for_slope));
end

