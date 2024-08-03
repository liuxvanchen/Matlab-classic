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
        lai_values(lai_values == 2550 | lai_values == 2500) = NaN;

        
        % 计算当前月份 LAI 的平均值并累加
        current_month_mean = nanmean(lai_values(:));
        
        % 清理 lai_values 变量以释放内存
        clear('lai_values');
        
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

% 假设 mean_lai 已经根据年份索引 year_idx 填充了每年的 LAI 平均值
for year_idx = 1:length(years)
    % 检查年份是否不是 2016、2019 和 2020
    if ~(year_idx == 35 || year_idx == 38 || year_idx == 39)
        % 如果年份不是这三个中的任何一个，则乘以0.1
        mean_lai(year_idx) = mean_lai(year_idx) * 0.1;
    end
end


% 绘制每年的 LAI 平均值折线图
figure;
plot(years, mean_lai, 'o-');
xlabel('Year');
ylabel('Average LAI');
title(['Yearly Average LAI from ' num2str(years(1)) ' to ' num2str(years(end)) ]);
grid on;