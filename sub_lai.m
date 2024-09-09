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

% 初始化存储差值的数组
lai_diff_all_pixels = NaN(num_mask_pixels, length(valid_month_indices));

% 遍历每个像元
for pixel_idx = 1:num_mask_pixels
    % 遍历每个月份
    for month_idx = 1:length(valid_month_indices)
        month = valid_month_indices(month_idx);
        
        % 找到该像元在该月份的干旱年份
        drought_years = drought_years_per_pixel{pixel_idx, month};
        
        % 如果没有干旱年份，跳过此月份
        if isempty(drought_years)
            continue;
        end
        
        %% 1. 计算干旱后两个月的 LAI 平均值（针对干旱年份）
        lai_drought_post_all = [];
        for year_idx = 1:length(drought_years)
            current_year = drought_years(year_idx);
            post_month1 = month + 1;  % 干旱后的第一个月
            post_month2 = month + 2;  % 干旱后的第二个月
            
            % 构建文件路径并读取 LAI 数据（后两个月）
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
                
                % 检查年份，如果是2019或2020年，乘以10进行缩放
                if current_year == 2019 || current_year == 2020
                    lai_values1 = lai_values1 * 10;
                    lai_values2 = lai_values2 * 10;
                end
                
                % 对 LAI 值进行有效性过滤（排除大于100和小于0的值）
                lai_values1(lai_values1 > 100 | lai_values1 < 0) = NaN;
                lai_values2(lai_values2 > 100 | lai_values2 < 0) = NaN;
                
                % 提取掩膜像元位置的 LAI 值
                lai_values_pixel1 = lai_values1(mask);
                lai_values_pixel2 = lai_values2(mask);
                
                % 计算该像元在这两个月的平均值
                lai_drought_post_all = [lai_drought_post_all; nanmean([lai_values_pixel1(pixel_idx), lai_values_pixel2(pixel_idx)])];
                
            catch
                warning('File not found for year %d, skipping to next year...', current_year);
                continue;
            end
        end
        
        % 如果没有可用的 LAI 数据，跳过此月份
        if isempty(lai_drought_post_all)
            continue;
        end
        
        %% 2. 计算39年间对应月份的 LAI 平均值
        lai_39_years_all = [];
        for year_idx = 1:num_years
            current_year = years(year_idx);
            post_month1 = month + 1;  % 对应的第一个月
            post_month2 = month + 2;  % 对应的第二个月
            
            % 构建文件路径并读取 LAI 数据（对应月份）
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
                
                % 检查年份，如果是2019或2020年，乘以10进行缩放
                if current_year == 2019 || current_year == 2020
                    lai_values1 = lai_values1 * 10;
                    lai_values2 = lai_values2 * 10;
                end
                
                % 对 LAI 值进行有效性过滤（排除大于100和小于0的值）
                lai_values1(lai_values1 > 100 | lai_values1 < 0) = NaN;
                lai_values2(lai_values2 > 100 | lai_values2 < 0) = NaN;
                
                % 提取掩膜像元位置的 LAI 值
                lai_values_pixel1 = lai_values1(mask);
                lai_values_pixel2 = lai_values2(mask);
                
                % 计算该像元在这两个月的平均值
                lai_39_years_all = [lai_39_years_all; nanmean([lai_values_pixel1(pixel_idx), lai_values_pixel2(pixel_idx)])];
                
            catch
                warning('File not found for year %d, skipping to next year...', current_year);
                continue;
            end
        end
        
        % 如果没有可用的39年间的 LAI 数据，跳过此月份
        if isempty(lai_39_years_all)
            continue;
        end
        
        %% 3. 计算干旱年份后两个月的 LAI 平均值与39年间平均值的差值
        drought_lai_mean = nanmean(lai_drought_post_all);  % 干旱年份后的两个月 LAI 平均值
        lai_39_years_mean = nanmean(lai_39_years_all);     % 39年间对应月份的 LAI 平均值
        
        % 计算差值并存储
        lai_diff_all_pixels(pixel_idx, month_idx) = drought_lai_mean - lai_39_years_mean;
    end
end

%% 输出差值结果
% 随机选择一个像元和一个月份，查看其干旱后LAI平均值与正常年份的差值
random_pixel_idx = randi(num_mask_pixels);
random_month_idx = randi(length(valid_month_indices));

fprintf('随机选择的掩膜像元 %d 在第 %d 月份的干旱后两个月LAI平均值与正常年份的差值: \n', random_pixel_idx, random_month_idx);
disp(lai_diff_all_pixels(random_pixel_idx, random_month_idx));

% 保存差值结果到 .mat 文件
save('lai_diff_data.mat', 'lai_diff_all_pixels');

disp('干旱后两个月LAI平均值与正常年份的差值数据已保存到 lai_diff_data.mat');
