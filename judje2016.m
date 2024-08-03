months=1:12;
base_lai_folder = 'F:\clip_lai2\2001';

lai_sum = 0;
count = 0;

% 遍历每个月份
for month = months
        lai_file = fullfile(base_lai_folder, sprintf('mean_lai2001%02d.tif', month));
        
        % 读取 LAI 数据
        lai_values = imread(lai_file);
        
        % 将 -9999 替换为 NaN
        %lai_values(lai_values == -2147483647) = NaN;

        lai_values(lai_values==-9999)=NaN;
        lai_values(lai_values == 2550 | lai_values == 2500) = NaN;

        
        % 计算当前月份 LAI 的平均值并累加
        current_month_mean = nanmean(lai_values(:));
        
        % 只有当平均值不是 NaN 时才累加
        if ~isnan(current_month_mean)
            lai_sum = lai_sum + current_month_mean;
            count = count + 1;
        end
end
% 计算每年的 LAI 平均值
if count > 0
    mean_lai = lai_sum / count;
    disp(mean_lai)
else
    mean_lai = NaN; % 如果某个年份没有任何有效数据，则设置为 NaN
end