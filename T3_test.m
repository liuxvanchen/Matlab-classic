base_lai_folder = 'F:\clip_lai2';

month_indices = 1:12;
years = 1982:2020;
num_years = length(years);

% 加载 drought_years_per_pixel 数据
load('drought_data3.mat', 'drought_years_per_pixel');

% 只处理2月至10月的月份
valid_month_indices = 2:10;  % 忽略1、11、12月

% 读取并处理掩膜TIFF文件
tif_file = 'F:\pnf\clip2020pnf.tif';
tif_data = imread(tif_file);

% 创建掩膜，选择数值为2的区域
mask = (tif_data == 2);

% 获取掩膜区域的像素数
num_mask_pixels = sum(mask(:));

% 初始化存储去趋势后的 LAI 数据
detrended_lai = NaN(num_mask_pixels, num_years, length(valid_month_indices));

% 遍历每个像元，进行去趋势处理
for pixel_idx = 1:num_mask_pixels
    for month_idx = 1:length(valid_month_indices)
        month = valid_month_indices(month_idx);
        
        % 初始化存储每年该月份的 LAI 值
        lai_values_per_year = NaN(num_years, 1);
        
        % 读取每年该月份的 LAI 数据
        for year_idx = 1:num_years
            current_year = years(year_idx);
            
            try
                lai_folder = fullfile(base_lai_folder, num2str(current_year));
                lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', current_year, month));
                lai_values = imread(lai_file);
                
                % 将 -9999 替换为 NaN
                lai_values(lai_values == -9999) = NaN;
                
                % 提取掩膜区域的 LAI 值
                lai_values_pixel = lai_values(mask);
                
                % 检查年份，如果是2019或2020年，乘以10进行缩放
                if current_year == 2019 || current_year == 2020
                    lai_values_pixel = lai_values_pixel * 10;
                end
                
                % 存储每年该月份的 LAI 值
                lai_values_per_year(year_idx) = lai_values_pixel(pixel_idx);
                
            catch
                warning('File not found for year %d, skipping to next year...', current_year);
                continue;
            end
        end
        
        % 对该像素点的时间序列进行去趋势处理
        X = (1:num_years)';  % 年份作为时间序列
        non_nan_idx = ~isnan(lai_values_per_year);
        
        if sum(non_nan_idx) > 1
            % 对 LAI 值进行线性回归去趋势
            p = polyfit(X(non_nan_idx), lai_values_per_year(non_nan_idx), 1);
            trend = polyval(p, X);
            detrended_lai(pixel_idx, :, month_idx) = lai_values_per_year - trend;
        else
            % 如果没有足够的数据点，保留原始数据
            detrended_lai(pixel_idx, :, month_idx) = lai_values_per_year;
        end
    end
end

% 初始化存储干旱后两个月 LAI 值和 39 年间这两个月 LAI 值的数组
lai_drought_post_all = [];
lai_39_years_all = [];

% 遍历每个像元
for pixel_idx = 1:num_mask_pixels
    % 遍历每个月份，找到干旱年份（例如：3月）
    drought_years = drought_years_per_pixel{pixel_idx, 4};  % 只处理3月
    
    % 如果没有3月的干旱年份，跳过此像元
    if isempty(drought_years)
        continue;
    end
    
    %% 1. 计算干旱后4月和5月的 LAI 平均值
    for year_idx = 1:length(drought_years)
        current_year = drought_years(year_idx);
        post_month1 = 5;  % 干旱后的第一个月
        post_month2 = 6;  % 干旱后的第二个月
        
        % 构建文件路径并读取 LAI 数据（4月和5月）
        try
            lai_folder1 = fullfile(base_lai_folder, num2str(current_year));
            lai_file1 = fullfile(lai_folder1, sprintf('mean_lai%04d%02d.tif', current_year, post_month1));
            lai_values1 = imread(lai_file1);
            
            lai_folder2 = fullfile(base_lai_folder, num2str(current_year));
            lai_file2 = fullfile(lai_folder2, sprintf('mean_lai%04d%02d.tif', current_year, post_month2));
            lai_values2 = imread(lai_file2);
            
            % 将 -9999 替换为 NaN
            lai_values1(lai_values1 == -9999) = NaN;
            lai_values2(lai_values2 == -9999) = NaN;
            
        catch
            warning('File not found for year %d, skipping to next year...', current_year);
            continue;
        end
        
        % 检查年份，如果是2019或2020年，乘以10进行缩放
        if current_year == 2019 || current_year == 2020
            lai_values1 = lai_values1 * 10;
            lai_values2 = lai_values2 * 10;
        end
        
        % 提取掩膜像元位置的 LAI 值
        lai_values_pixel1 = lai_values1(mask);
        lai_values_pixel2 = lai_values2(mask);
        
        % 计算这两个月的平均值并存入集合中
        lai_drought_post_all = [lai_drought_post_all; nanmean([lai_values_pixel1(pixel_idx), lai_values_pixel2(pixel_idx)])];
    end
    
    %% 2. 计算39年间4月和5月的 LAI 平均值（针对当前像元）
    for year_idx = 1:num_years
        current_year = years(year_idx);
        post_month1 = 5;  % 4月
        post_month2 = 6;  % 5月
        
        % 构建文件路径并读取 LAI 数据（4月和5月）
        try
            lai_folder1 = fullfile(base_lai_folder, num2str(current_year));
            lai_file1 = fullfile(lai_folder1, sprintf('mean_lai%04d%02d.tif', current_year, post_month1));
            lai_values1 = imread(lai_file1);
            
            lai_folder2 = fullfile(base_lai_folder, num2str(current_year));
            lai_file2 = fullfile(lai_folder2, sprintf('mean_lai%04d%02d.tif', current_year, post_month2));
            lai_values2 = imread(lai_file2);
            
            % 将 -9999 替换为 NaN
            lai_values1(lai_values1 == -9999) = NaN;
            lai_values2(lai_values2 == -9999) = NaN;
            
        catch
            warning('File not found for year %d, skipping to next year...', current_year);
            continue;
        end
        
        % 检查年份，如果是2019或2020年，乘以10进行缩放
        if current_year == 2019 || current_year == 2020
            lai_values1 = lai_values1 * 10;
            lai_values2 = lai_values2 * 10;
        end
        
        % 提取掩膜像元位置的 LAI 值
        lai_values_pixel1 = lai_values1(mask);
        lai_values_pixel2 = lai_values2(mask);
        
        % 计算两个月的平均值并存入集合中
        lai_39_years_all = [lai_39_years_all; nanmean([lai_values_pixel1(pixel_idx), lai_values_pixel2(pixel_idx)])];
    end
end

%% 3. 进行显著性检验
% 如果数据满足正态性假设，使用 t 检验
[h, p] = ttest2(lai_drought_post_all, lai_39_years_all);

% 输出检验结果
disp('显著性检验结果：');
disp(['h = ', num2str(h)]);
disp(['p-value = ', num2str(p)]);
