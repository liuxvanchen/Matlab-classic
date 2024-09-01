base_lai_folder = 'F:\clip_lai2';

% 初始化年份和月份信息 (示例异常干旱月份)
% 每个条目格式为 [year, month]
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
mask = (tif_data == 2);
% | tif_data == 2

% 创建一个新的图形窗口
figure;

% 遍历每个异常干旱月份
for i = 1:size(dry_months, 1)
    year = dry_months(i, 1);
    start_month = dry_months(i, 2);
    
    % 初始化数组来存储 LAI 值
    lai_values = NaN(1, 3);  % 存储当前月及其后两个月的LAI值
    
    % 遍历当前月份及其之后的两个月
    for j = 0:2
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
            lai_values(j + 1) = nanmean(masked_lai_values);
        end
    end
    
    % 在一个子图（subplot）中绘制当前异常月份的 LAI 变化折线图
    subplot(2, 3, i);  % 2x3的布局
    plot(0:2, lai_values, '-o');
    title(sprintf('LAI Changes for %d-%02d and the Following 2 Months', year, start_month));
    xlabel('Months (0 = current month, 1 = next month, 2 = two months later)');
    ylabel('LAI Average');
    grid on;
end

% 调整子图的布局
sgtitle('LAI Changes for Selected Drought Months and Following Periods');
