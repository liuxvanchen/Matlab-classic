base_lai_folder = 'F:\clip_lai2';

% 初始化年份和月份信息 (示例异常干旱月份)
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

% 创建掩膜，选择数值为 2 和 33 的区域
mask = (tif_data == 33 | tif_data == 2);

% 初始化存储LAI变化的数组
lai_diff_values = [];

% 遍历每个异常干旱月份
for i = 1:size(dry_months, 1)
    year = dry_months(i, 1);
    start_month = dry_months(i, 2);
    
    % 初始化异常月份之后三个月的LAI平均值
    lai_values = NaN(1, 3);
    
    % 遍历异常月份后的三个月
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
    
    % 计算这三个月的平均值
    lai_avg_abnormal = nanmean(lai_values);
    
    % 计算39年间对应三个月的历史平均LAI值
    historical_lai_values = [];
    
    for j = 1:3
        month = start_month + j;
        current_years = years;
        
        % 检查是否跨年
        if month > 12
            month = month - 12;
            current_years = years(2:end); % 跨年的情况，跳过第一个年份
        end
        
        monthly_lai_values = NaN(1, length(current_years));
        
        for k = 1:length(current_years)
            current_year = current_years(k);
            lai_folder = fullfile(base_lai_folder, num2str(current_year));
            lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', current_year, month));
            
            if exist(lai_file, 'file')
                lai_data = imread(lai_file);
                
                % 将 -9999 替换为 NaN
                lai_data(lai_data == -9999) = NaN;
                
                % 只保留掩膜区域的数据
                masked_lai_values = lai_data(mask);
                
                % 计算掩膜区域内LAI的平均值
                monthly_lai_values(k) = nanmean(masked_lai_values);
            end
        end
        
        historical_lai_values = [historical_lai_values, nanmean(monthly_lai_values)];
    end
    
    % 计算历史三个月的平均值
    historical_lai_avg = nanmean(historical_lai_values);
    
    % 计算差异
    lai_diff = lai_avg_abnormal - historical_lai_avg;
    lai_diff=lai_diff*0.1;
    lai_diff_values = [lai_diff_values; lai_diff];  % 保存差异值
    
    % 输出结果
    fprintf('Year: %d, Start Month: %d, LAI Difference: %.2f\n', year, start_month, lai_diff);
end

% 假设 lai_diff_values 已经包含了异常年份的LAI差值（经过0.1倍缩放后）
% 接下来计算正常年份相同月份的LAI差值

% 初始化存储正常年份LAI变化的数组
normal_lai_diff_values = [];

% 遍历39年中的所有年份，排除异常年份
for year_idx = 1:length(years)
    year = years(year_idx);
    
    % 检查该年份是否属于异常年份
    if ismember(year, dry_months(:, 1))
        continue; % 跳过异常年份
    end
    
    % 计算正常年份对应月份的LAI差值
    for month_idx = 1:size(dry_months, 1)
        start_month = dry_months(month_idx, 2);
        
        % 初始化三个月的LAI平均值
        lai_values = NaN(1, 3);
        
        % 遍历异常月份后的三个月
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
        
        % 计算这三个月的平均值
        lai_avg_normal = nanmean(lai_values);
        
        % 计算正常年份的历史三个月平均值
        historical_lai_values = [];
        
        for j = 1:3
            month = start_month + j;
            current_years = years;
            
            % 检查是否跨年
            if month > 12
                month = month - 12;
                current_years = years(2:end); % 跨年的情况，跳过第一个年份
            end
            
            monthly_lai_values = NaN(1, length(current_years));
            
            for k = 1:length(current_years)
                current_year = current_years(k);
                lai_folder = fullfile(base_lai_folder, num2str(current_year));
                lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', current_year, month));
                
                if exist(lai_file, 'file')
                    lai_data = imread(lai_file);
                    
                    % 将 -9999 替换为 NaN
                    lai_data(lai_data == -9999) = NaN;
                    
                    % 只保留掩膜区域的数据
                    masked_lai_values = lai_data(mask);
                    
                    % 计算掩膜区域内LAI的平均值
                    monthly_lai_values(k) = nanmean(masked_lai_values);
                end
            end
            
            historical_lai_values = [historical_lai_values, nanmean(monthly_lai_values)];
        end
        
        % 计算历史三个月的平均值
        historical_lai_avg = nanmean(historical_lai_values);
        
        % 计算差异
        lai_diff = lai_avg_normal - historical_lai_avg;
        normal_lai_diff_values = [normal_lai_diff_values; lai_diff];  % 保存差异值
    end
end

% 执行独立样本t检验
[h, p] = ttest2(lai_diff_values, normal_lai_diff_values);

% 输出显著性检验结果
fprintf('t-test Result: h = %d, p = %.4f\n', h, p);

if h == 1
    disp('There is a significant difference between the LAI differences of abnormal and normal years.');
else
    disp('There is no significant difference between the LAI differences of abnormal and normal years.');
end
