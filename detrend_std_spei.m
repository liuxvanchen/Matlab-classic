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
masked_spei = NaN(num_mask_pixels, num_years, length(month_indices));

% 遍历每个年份和每个月份，读取SPEI数据
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

%% 1. 去趋势处理

% 初始化一个数组来存储去趋势后的 SPEI 数据
detrended_spei = NaN(size(masked_spei));

% 对每个掩膜像元进行线性回归去趋势处理
for pixel_idx = 1:num_mask_pixels
    for month_idx = 1:length(month_indices)
        % 提取当前像元在39年间的SPEI值
        spei_values = squeeze(masked_spei(pixel_idx, :, month_idx));  % 不进行转置，保持原样
        
        % 生成时间序列（年份）
        X = (1:num_years)';
        
        % 只对非NaN的SPEI值进行线性回归
        non_nan_idx = ~isnan(spei_values);
        
        if sum(non_nan_idx) > 1
            % 对该月份进行线性回归
            p = polyfit(X(non_nan_idx), spei_values(non_nan_idx), 1);  % 一阶多项式拟合
            
            % 计算趋势（即线性回归拟合的值）
            trend = polyval(p, X);
            
            % 去趋势处理，确保 spei_values 和 trend 都是列向量
            spei_values = spei_values(:);  % 强制为列向量
            trend = trend(:);              % 强制为列向量
            
            % 执行去趋势操作
            detrended_spei(pixel_idx, :, month_idx) = spei_values - trend;
        else
            % 如果SPEI值中没有足够的有效数据点，保留为NaN
            detrended_spei(pixel_idx, :, month_idx) = spei_values;
        end
    end
end

%% 2. 计算去趋势后的平均值和标准差
mean_spei_per_pixel = squeeze(nanmean(detrended_spei, 2));  % 计算每个月的去趋势后的均值
std_spei_per_pixel = squeeze(nanstd(detrended_spei, 0, 2)); % 计算每个月的去趋势后的标准差

%% 3. 筛选干旱年份（小于平均值 - 2 * 标准差）
% 初始化一个数组来存储每个像元每个月的干旱年月份
drought_years_per_pixel = cell(num_mask_pixels, length(month_indices));

% 遍历每个掩膜像元，筛选干旱年份
for pixel_idx = 1:num_mask_pixels
    for month_idx = 1:length(month_indices)
        % 计算该月的干旱阈值（去趋势后的数据）
        drought_threshold = mean_spei_per_pixel(pixel_idx, month_idx) - 2 * std_spei_per_pixel(pixel_idx, month_idx);
        
        % 找到所有该月 SPEI 小于干旱阈值的年份
        drought_years = years(detrended_spei(pixel_idx, :, month_idx) < drought_threshold);
        
        % 将结果存入 drought_years_per_pixel 对应的 cell 中
        drought_years_per_pixel{pixel_idx, month_idx} = drought_years;
    end
end

%% 4. 输出示例结果
% 随机选择一个像元和一个月份，查看其去趋势后的干旱年年份
random_pixel_idx = randi(num_mask_pixels);
random_month_idx = randi(length(month_indices));

fprintf('随机选择的掩膜像元 %d 在第 %d 月份的去趋势后干旱年年份: \n', random_pixel_idx, random_month_idx);
disp(drought_years_per_pixel{random_pixel_idx, random_month_idx});

% 保存结果到 .mat 文件
save('drought_data.mat', 'drought_years_per_pixel');

disp('干旱年份数据已保存到 drought_data.mat');