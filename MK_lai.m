% 基础 LAI 文件夹路径
base_lai_folder = 'F:\clip_lai2';

month_indices = 1:12;
years = 1982:2020;
num_years = length(years);

% 加载 drought_years_per_pixel 数据
load('drought_data.mat', 'drought_years_per_pixel');

% 只处理2月至10月的月份
valid_month_indices = 2:10;  % 忽略1、11、12月

% 读取并处理掩膜TIFF文件
tif_file = 'F:\pnf\clip2020pnf.tif';
tif_data = imread(tif_file);

% 创建掩膜，选择数值为2的区域
mask = (tif_data == 2);

% 获取掩膜区域的像素数
num_mask_pixels = sum(mask(:));

% 初始化一个 cell 数组来存储显著性检验结果
significance_test_results = cell(num_mask_pixels, length(valid_month_indices));

% 遍历每个像元
for pixel_idx = 1:num_mask_pixels
    % 遍历有效的月份，找到干旱年份
    for valid_month_idx = 1:length(valid_month_indices)
        month_idx = valid_month_indices(valid_month_idx);  % 当前处理的月份索引
        
        % 获取当前月份的干旱年份
        drought_years = drought_years_per_pixel{pixel_idx, month_idx};
        
        if isempty(drought_years)
            continue;  % 如果没有干旱年份，跳过
        end
        
        %% 1. 计算干旱后两个月的 LAI 平均值
        lai_drought_post_mean = NaN(length(drought_years), 1);  % 用于存储干旱后两个月的平均值
        
        for year_idx = 1:length(drought_years)
            current_year = drought_years(year_idx);
            post_month1 = month_idx + 1;  % 干旱后的第一个月
            post_month2 = month_idx + 2;  % 干旱后的第二个月
            
            % 构建文件路径并读取 LAI 数据（干旱后两个月）
            lai_folder1 = fullfile(base_lai_folder, num2str(current_year));
            lai_file1 = fullfile(lai_folder1, sprintf('mean_lai%04d%02d.tif', current_year, post_month1));
            lai_values1 = imread(lai_file1);
            lai_folder2 = fullfile(base_lai_folder, num2str(current_year));
            lai_file2 = fullfile(lai_folder2, sprintf('mean_lai%04d%02d.tif', current_year, post_month2));
            lai_values2 = imread(lai_file2);
            
            % 检查年份，如果是2019或2020年，乘以10进行缩放
            if current_year == 2019 || current_year == 2020
                lai_values1 = lai_values1 * 10;
                lai_values2 = lai_values2 * 10;
            end
            
            % 提取掩膜像元位置的 LAI 值
            lai_values_pixel1 = lai_values1(mask);
            lai_values_pixel2 = lai_values2(mask);
            
            % 计算干旱后两个月的平均值
            lai_drought_post_mean(year_idx) = nanmean([lai_values_pixel1(pixel_idx), lai_values_pixel2(pixel_idx)]);
        end
        
        %% 2. 计算39年间相应月份的 LAI 平均值
        lai_39_years_mean = NaN(num_years, 1);  % 用于存储39年每年两个相应月份的平均值
        
        for year_idx = 1:num_years
            current_year = years(year_idx);
            
            % 构建文件路径并读取 LAI 数据（两个月）
            lai_folder1 = fullfile(base_lai_folder, num2str(current_year));
            lai_file1 = fullfile(lai_folder1, sprintf('mean_lai%04d%02d.tif', current_year, post_month1));
            lai_values1 = imread(lai_file1);
            lai_folder2 = fullfile(base_lai_folder, num2str(current_year));
            lai_file2 = fullfile(lai_folder2, sprintf('mean_lai%04d%02d.tif', current_year, post_month2));
            lai_values2 = imread(lai_file2);
            
            % 检查年份，如果是2019或2020年，乘以10进行缩放
            if current_year == 2019 || current_year == 2020
                lai_values1 = lai_values1 * 10;
                lai_values2 = lai_values2 * 10;
            end
            
            % 提取掩膜像元位置的 LAI 值
            lai_values_pixel1 = lai_values1(mask);
            lai_values_pixel2 = lai_values2(mask);
            
            % 计算两个月的平均值
            lai_39_years_mean(year_idx) = nanmean([lai_values_pixel1(pixel_idx), lai_values_pixel2(pixel_idx)]);
        end
        
        %% 3. 进行显著性检验 (Mann-Kendall 检验)
        % 使用 t 检验或 Mann-Whitney U 检验来比较干旱后两个月的LAI和39年间的LAI均值

        % 如果数据满足正态性假设，使用 t 检验:
        [h, p] = ttest2(lai_drought_post_mean, lai_39_years_mean);
        
        % 如果数据不满足正态性假设，使用 Mann-Whitney U 检验（非参数检验）:
        % [p, h] = ranksum(lai_drought_post_mean, lai_39_years_mean);
        
        % 存储显著性检验结果
        significance_test_results{pixel_idx, valid_month_idx} = struct('h', h, 'p_value', p);


    end
end

% 输出或存储显著性检验结果
disp('显著性检验完成');
