base_lai_folder = 'F:\clip_lai2';

% [year, month] - 异常干旱月份
dry_months = [
    1988, 12;
    1995, 6;
    1998, 11;
    1999, 2;
    2004, 4;
    2006, 10
];

% 读取并处理掩膜TIFF文件
tif_file = 'F:\pnf\clip2020pnf.tif';
tif_data = imread(tif_file);

% 创建掩膜，选择数值为2的区域
mask = (tif_data == 2);

% 初始化存储LAI变化的数组
lai_diff_values = [];

% 遍历每个异常干旱月份
for i = 1:size(dry_months, 1)
    year = dry_months(i, 1);
    start_month = dry_months(i, 2);
    
    % 初始化异常月份之后两个月的LAI平均值
    lai_values = NaN(1, 2);
    
    % 遍历异常月份后的两个月
    for j = 1:3
        current_month = start_month + j;
        current_year = year;
        
        % 检查是否跨年
        if current_month > 12
            current_month = current_month - 12;
            current_year = current_year + 1;
        end
        
        % 构建文件路径并读取LAI数据
        lai_folder = fullfile(base_lai_folder, num2str(current_year));
        lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', current_year, current_month));
        
        if exist(lai_file, 'file')
            lai_data = imread(lai_file);
            
            % 将 -9999 替换为 NaN
            lai_data(lai_data == -9999) = NaN;
            
            % 只保留掩膜区域的数据
            masked_lai_values = lai_data(mask);
            
            % 计算掩膜区域内LAI的平均值
            lai_values(j) = nanmean(masked_lai_values);
        end
    end
    
    % 计算异常月份后两个月的LAI平均值
    lai_avg_abnormal = nanmean(lai_values);
    
    % 初始化存储39年历史数据的数组
    historical_lai_values = [];
    
    % 计算39年间对应两个月的历史平均LAI值
    for year = 1981:2019
        monthly_lai_values = NaN(1, 2);
        
        for j = 1:3
            current_month = start_month + j;
            current_year = year;
            
            % 检查是否跨年
            if current_month > 12
                current_month = current_month - 12;
                current_year = current_year + 1;
            end
            
            % 构建文件路径并读取LAI数据
            lai_folder = fullfile(base_lai_folder, num2str(current_year));
            lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', current_year, current_month));
            
            if exist(lai_file, 'file')
                lai_data = imread(lai_file);
                
                % 将 -9999 替换为 NaN
                lai_data(lai_data == -9999) = NaN;
                
                % 只保留掩膜区域的数据
                masked_lai_values = lai_data(mask);
                
                % 计算掩膜区域内LAI的平均值
                monthly_lai_values(j) = nanmean(masked_lai_values);
            end
        end
        
        % 计算当前年份对应两个月的LAI平均值，并存储到历史数据中
        historical_lai_values = [historical_lai_values, nanmean(monthly_lai_values)];
    end
    
    % 计算历史两个月的平均LAI值
    historical_lai_avg = nanmean(historical_lai_values);
    
    % 计算异常月份后的两个月与历史平均LAI的差异
    lai_diff = lai_avg_abnormal - historical_lai_avg;
    lai_diff=lai_diff*0.1;
    lai_diff_values = [lai_diff_values; lai_diff];  % 保存差异值
    
    % 输出结果
    fprintf('Year: %d, Start Month: %d, LAI Difference: %.2f\n', dry_months(i, 1), start_month, lai_diff);
end

% 计算LAI差异值与零的显著性检验
[p_value, h] = signrank(lai_diff_values);

% 输出检验结果
if h == 1
    fprintf('LAI差异与零有显著差异，p值为: %.4f\n', p_value);
else
    fprintf('LAI差异与零无显著差异，p值为: %.4f\n', p_value);
end

