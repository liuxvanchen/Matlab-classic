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
mask_indices = find(mask);  % 获取掩膜区域的像元索引
num_mask_pixels = length(mask_indices);  % 获取掩膜区域像元的数量

% 从掩膜像元中随机抽取 1000 个像元
num_samples = 1000;
if num_mask_pixels < num_samples
    error('掩膜中的像元数少于 1000 个，无法抽取足够的样本。');
end
sampled_indices = randsample(num_mask_pixels, num_samples);  % 随机抽取 1000 个像元的索引

% 初始化存储干旱后两个月 LAI 值和 39 年间这两个月 LAI 值的数组
lai_drought_post_all = [];
lai_39_years_all = [];

% 遍历随机抽取的1000个像元
for sample_idx = 1:num_samples
    % 获取在 drought_years_per_pixel 中对应的索引
    pixel_idx = sampled_indices(sample_idx);
    
    % 遍历每个月份，找到干旱年份（例如：4月）
    drought_years = drought_years_per_pixel{pixel_idx, 4};  % 只处理4月
    
    % 如果没有4月的干旱年份，跳过此像元
    if isempty(drought_years)
        continue;
    end
    
    %% 1. 计算干旱后5月和6月的 LAI 平均值
    for year_idx = 1:length(drought_years)
        current_year = drought_years(year_idx);
        post_month1 = 5;  % 干旱后的第一个月
        post_month2 = 6;  % 干旱后的第二个月
        
        % 构建文件路径并读取 LAI 数据（5月和6月）
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
    
    %% 2. 计算39年间5月和6月的 LAI 平均值（针对当前像元）
    for year_idx = 1:num_years
        current_year = years(year_idx);
        post_month1 = 5;  % 5月
        post_month2 = 6;  % 6月
        
        % 构建文件路径并读取 LAI 数据（5月和6月）
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

