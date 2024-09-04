base_spei_folder = 'F:\clip_spei';

month_indices = 1:12;
years = 1982:2020;
num_years = length(years);

% 读取并处理掩膜TIFF文件
tif_file = 'F:\pnf\clip2020pnf.tif';
tif_data = imread(tif_file);

% 创建掩膜，选择数值为2的区域
mask = (tif_data == 2);

% 获取掩膜区域的像素数
num_mask_pixels = sum(mask(:));

% 初始化一个数组来存储每个掩膜位置的 spei 值
% 数组大小为 [num_mask_pixels, num_years, num_months]
masked_spei = NaN(num_mask_pixels, num_years, length(month_indices));

% 遍历每个年份和每个月份
for year_idx = 1:num_years
    year = years(year_idx);
    spei_folder = fullfile(base_spei_folder, num2str(year));
    
    for month_idx = 1:length(month_indices)
        month = month_indices(month_idx);
        spei_file = fullfile(spei_folder, sprintf('spei_%04d_%02d.tif', year, month));
        
        % 读取 spei 数据
        spei_values = imread(spei_file);
        
        % 将 -9999 替换为 NaN，并移除无效值
        spei_values(spei_values == -9999 | spei_values == 2550 | spei_values == 2500) = NaN;
        
        % 提取掩膜区域的 spei 值并存储
        mask_lai = spei_values(mask);
        
        % 将该月的值存入对应的年份和月份
        masked_spei(:, year_idx, month_idx) = mask_lai;
    end
end

% 对每个掩膜位置计算 spei 时间序列的平均值 (跨年)
mean_spei_per_pixel = squeeze(nanmean(masked_spei, 2));  % 计算每个月的均值

% 随机选择一个掩膜像元进行输出
random_pixel_idx = randi(num_mask_pixels);

fprintf('随机选择的掩膜像元 %d 的12个月平均SPEI值: \n', random_pixel_idx);
disp(mean_spei_per_pixel(random_pixel_idx, :));

% 对每个掩膜位置计算 spei 时间序列的标准差 (跨年)
std_spei_per_pixel = squeeze(nanstd(masked_spei, 0, 2));  % 计算每个月的标准差

% 随机选择一个掩膜像元进行输出
random_pixel_idx = randi(num_mask_pixels);

fprintf('随机选择的掩膜像元 %d 的12个月SPEI标准差: \n', random_pixel_idx);
disp(std_spei_per_pixel(random_pixel_idx, :));

% 初始化一个数组来存储每个像元每个月的干旱年月份
drought_years_per_pixel = cell(num_mask_pixels, length(month_indices));

% 遍历每个掩膜像元
for pixel_idx = 1:num_mask_pixels
    % 遍历每个月
    for month_idx = 1:length(month_indices)
        % 计算该月的干旱阈值
        drought_threshold = mean_spei_per_pixel(pixel_idx, month_idx) - 2 * std_spei_per_pixel(pixel_idx, month_idx);
        
        % 找到所有该月 SPEI 小于干旱阈值的年份
        drought_years = years(masked_spei(pixel_idx, :, month_idx) < drought_threshold);
        
        % 将结果存入 drought_years_per_pixel 对应的 cell 中
        drought_years_per_pixel{pixel_idx, month_idx} = drought_years;
    end
end

% 输出结果示例：随机选择一个像元和一个月份，查看其干旱年份
random_pixel_idx = randi(num_mask_pixels);
random_month_idx = randi(length(month_indices));

fprintf('随机选择的掩膜像元 %d 在第 %d 月份的干旱年年份: \n', random_pixel_idx, random_month_idx);
disp(drought_years_per_pixel{2171, 7});
