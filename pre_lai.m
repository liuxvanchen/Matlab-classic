% 文件夹路径
lai_folder = 'F:\clip_lai\2020\';
pre_folder = 'F:\clip_pre\2020\';

% 初始化存储数据的数组pre
months = 1:12;
lai_data = cell(1, 12);
pre_data = cell(1, 12);

% 遍历每个月份
for month = months
    lai_file = fullfile(lai_folder, sprintf('mean_lai2020%02d.tif', month));
    pre_file = fullfile(pre_folder, sprintf('pre2020_%02d_0.05.tif', month));
    
    % 读取 SPEI 和 precipitation 数据
    lai_values = imread(lai_file);
    pre_values = imread(pre_file);
    
    % 将数据添加到单元数组中
    lai_data{month} = lai_values;
    pre_data{month} = pre_values;
end

% 将单元数组转换为数组
lai_data = cat(3, lai_data{:});
pre_data = cat(3, pre_data{:});

% 初始化数组以存储相关系数
correlation_coefficients = NaN(size(lai_data, 1), size(lai_data, 2));

% 对每个像元位置进行相关性分析
for i = 477:size(lai_data, 1)
    for j =817:size(lai_data, 2)
        lai_time_series = reshape(double(lai_data(i, j, :)), [], 1);  % 转换为双精度浮点数
        pre_time_series = reshape(double(pre_data(i, j, :)), [], 1);
        
        % 过滤 NaN 和 Inf
        time_series_mask = ~isnan(lai_time_series) & ~isinf(lai_time_series) & ~isnan(pre_time_series) & ~isinf(pre_time_series);
        lai_time_series_filtered = lai_time_series(time_series_mask);
        pre_time_series_filtered = pre_time_series(time_series_mask);
        
        % 确保至少有两个有效数据点才能计算相关性
        if sum(time_series_mask) >= 2
            % 计算 Pearson 相关系数
            corr_coeff = corr(lai_time_series_filtered, pre_time_series_filtered);
            
            % 存储相关系数
            correlation_coefficients(i, j) = corr_coeff;
        else
            correlation_coefficients(i, j) = NaN;  % 如果有效数据点不足，存储 NaN
        end
    end
end

% 读取和处理掩膜TIFF文件
tif_file = 'F:\pnf\clip2020pnf.tif';
tif_data = imread(tif_file);

% 创建掩膜，选择数值为 2 和 33 的区域
mask = (tif_data == 2) | (tif_data == 33);
%(tif_data == 2) | 

% 提取符合掩膜条件的相关系数
selected_coefficients = correlation_coefficients(mask);

% 计算平均值
average_coefficient = nanmean(selected_coefficients(:));

% 输出平均值
fprintf('选定区域的相关系数平均值为: %.4f\n', average_coefficient);
