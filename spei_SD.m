base_spei_folder = 'F:\clip_spei';

month_indices = 1:12;
years = 1982:2020;

% 初始化一个数组来存储每个月的 spei 值
all_monthly_spei = NaN(length(years), length(month_indices)); % 预先分配数组大小

% 遍历每个年份
for year_idx = 1:length(years)
    year = years(year_idx);
    spei_folder = fullfile(base_spei_folder, num2str(year));
    
    % 遍历每个月份
    for month_idx = 1:length(month_indices)
        month = month_indices(month_idx);
        spei_file = fullfile(spei_folder, sprintf('spei_%04d_%02d.tif', year, month));
        
        % 读取 spei 数据
        spei_values = imread(spei_file);
        
        % 将 -9999 替换为 NaN
        spei_values(spei_values == -9999) = NaN;
        spei_values(spei_values == 2550 | spei_values == 2500) = NaN;

        % 计算整个图像的 spei 平均值并累加
        current_month_mean = nanmean(spei_values(:)); % 计算所有像素的均值，确保返回标量

        % 清理 spei_values 变量以释放内存
        clear('spei_values');
        
        % 只有当平均值不是 NaN 时才存储
        if ~isnan(current_month_mean)
            all_monthly_spei(year_idx, month_idx) = current_month_mean;
        end
    end
end

% 计算每个月的 spei 标准差
monthly_spei_std = nanstd(all_monthly_spei, 0, 1); % 第二个参数0表示样本标准差，1表示沿列方向计算
monthly_spei_mean = nanmean(all_monthly_spei);

% 显示结果
disp('39年间每个月的SPEI标准差:');
disp(monthly_spei_std);

disp('39年间每个月的SPEI平均值:');
disp(monthly_spei_mean);

% 初始化一个数组来存储低于范围内的年月份及其具体情况
lower_out_of_range_years_months = [];

% 遍历每个年份和月份，筛选出低于平均值-1倍标准差的SPEI值
for year_idx = 1:length(years)
    for month_idx = 1:length(month_indices)
        spei_value = all_monthly_spei(year_idx, month_idx);
        lower_bound = monthly_spei_mean(month_idx) - 1 * monthly_spei_std(month_idx);
        
        % 检查当前月份的SPEI值是否低于范围
        if ~isnan(spei_value) && spei_value < lower_bound
            % 记录低于范围的年和月份
            lower_out_of_range_years_months = [lower_out_of_range_years_months; years(year_idx), month_indices(month_idx), spei_value];
        end
    end
end

% 显示低于范围内的年月份及其具体情况
disp('低于 SPEI 平均值 - 1 倍标准差范围内的年月份 (格式: 年, 月, SPEI值):');
for i = 1:size(lower_out_of_range_years_months, 1)
    year = lower_out_of_range_years_months(i, 1);
    month = lower_out_of_range_years_months(i, 2);
    spei_value = lower_out_of_range_years_months(i, 3);
    fprintf('Year: %d, Month: %d, SPEI: %.2f\n', year, month, spei_value);
end