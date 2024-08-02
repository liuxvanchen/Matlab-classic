% 文件夹路径
base_lai_folder = 'F:\clip_lai';
base_tmp_folder = 'F:\clip_tmp';

% 初始化存储数据的cell数组，用于39*12个月的数据
months = 1:468; % 468个月的数据
years = 1982:2020; % 年份范围
lai_data_cell = cell(1, length(months));
tmp_data_cell = cell(1, length(months));

% 遍历每120个月份
for month_idx = 1:length(months)
    year = floor((month_idx - 1) / 12) + 1982; % 计算年份
    month = mod(month_idx - 1, 12) + 1; % 计算月份
    
    lai_folder = fullfile(base_lai_folder, num2str(year));
    tmp_folder = fullfile(base_tmp_folder, num2str(year));
    
    % 构建文件名
    lai_file = fullfile(lai_folder, sprintf('mean_lai%04d%02d.tif', year, month));
    tmp_file = fullfile(tmp_folder, sprintf('tmp%04d_%02d_0.05.tif', year, month));
    
    % 读取 SPEI 和 tmpcipitation 数据
    lai_values = imread(lai_file);
    tmp_values = imread(tmp_file);
    
    % 将数据添加到单元数组中
    lai_data_cell{month_idx} = lai_values;
    tmp_data_cell{month_idx} = tmp_values;
end

% 将单元数组转换为数组
lai_data = cat(3, lai_data_cell{:});
tmp_data = cat(3, tmp_data_cell{:});


% 初始化数组以存储相关系数
correlation_coefficients = NaN(size(lai_data, 1), size(lai_data, 2));

% 对每个像元位置进行相关性分析
for i = 1:size(lai_data, 1)
    for j = 1:size(lai_data, 2)
        lai_time_series = reshape(double(lai_data(i, j, :)), [], 1);  % 转换为双精度浮点数
        tmp_time_series = reshape(double(tmp_data(i, j, :)), [], 1);
        
        % 过滤 NaN 和 Inf
        time_series_mask = ~isnan(lai_time_series) & ~isinf(lai_time_series) & ~isnan(tmp_time_series) & ~isinf(tmp_time_series);
        lai_time_series_filtered = lai_time_series(time_series_mask);
        tmp_time_series_filtered = tmp_time_series(time_series_mask);
        
        % 确保至少有两个有效数据点才能计算相关性
        if sum(time_series_mask) >= 2
            % 计算 Pearson 相关系数
            corr_coeff = corr(lai_time_series_filtered, tmp_time_series_filtered);
            
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
mask = (tif_data == 2) |(tif_data == 33);
%(tif_data == 2) | 

% 提取符合掩膜条件的相关系数
selected_coefficients = correlation_coefficients(mask);

% 计算平均值
average_coefficient = nanmean(selected_coefficients(:));

% 输出平均值
fprintf('选定区域气温-LAI的1982-2020年相关系数平均值为: %.4f\n', average_coefficient);

mask33 = (tif_data == 33);


% 提取符合掩膜条件的相关系数
selected_coefficients33 = correlation_coefficients(mask33);

% 计算平均值
average_coefficient33 = nanmean(selected_coefficients33(:));
fprintf('选定区域气温-LAI的1982-2020年人工林（33）相关系数平均值为: %.4f\n', average_coefficient33);

mask2 = (tif_data == 2) ;

% 提取符合掩膜条件的相关系数
selected_coefficients2 = correlation_coefficients(mask2);

% 计算平均值
average_coefficient2 = nanmean(selected_coefficients2(:));
fprintf('选定区域气温-LAI的1982-2020年天然林（2）相关系数平均值为: %.4f\n', average_coefficient2);

%xlswrite('F:\Excel\tmplai相关系数.xlsx',correlation_coefficients)
