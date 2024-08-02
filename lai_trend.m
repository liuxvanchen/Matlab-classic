base_lai_folder = 'F:\clip_lai';

% 初始化一个数组来存储每年的 LAI 平均值
mean_lai = NaN(length(years), 1); % 预先分配数组大小

months = 1:12;
years = 1982:2020;

% 遍历每个年份
for year_idx = 1:length(years)
    year = years(year_idx);
    lai_folder = fullfile(base_lai_folder, num2str(year));
    
    % 初始化一个变量来累加每个月的 LAI 值和计数器
    lai_sum = 0;
    count = 0;
    
    % 遍历每个月份
    for month = months
        lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', year, month));
        
        % 读取 LAI 数据
        lai_values = imread(lai_file);
        
        % 将 -9999 替换为 NaN
        lai_values(lai_values == -9999) = NaN;
        
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
        mean_lai(year_idx) = lai_sum / count;
    else
        mean_lai(year_idx) = NaN; % 如果某个年份没有任何有效数据，则设置为 NaN
    end
end

% 绘制每年的 LAI 平均值折线图
figure;
plot(years, mean_lai, 'o-');
xlabel('Year');
ylabel('Average LAI');
title('Yearly Average LAI from 1982 to 2020');
grid on;