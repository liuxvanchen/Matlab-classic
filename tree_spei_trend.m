base_spei_folder = 'F:\clip_spei';

% 初始化一个数组来存储每年的 spei 平均值
mean_spei = NaN(length(years), 1); % 预先分配数组大小

months = 1:12;
years = 1982:2020;

% 遍历每个年份
for year_idx = 1:length(years)
    year = years(year_idx);
    spei_folder = fullfile(base_spei_folder, num2str(year));
    
    % 初始化一个变量来累加每个月的 spei 值和计数器
    spei_sum = 0;
    count = 0;
    
    % 遍历每个月份
    for month = months
        spei_file = fullfile(spei_folder, sprintf('spei_%04d_%02d.tif', year, month));
        
        % 读取 spei 数据
        spei_values = imread(spei_file);
        
        % 将 -9999 替换为 NaN
        spei_values(spei_values == -9999) = NaN;
        spei_values(spei_values == 2550 | spei_values == 2500) = NaN;

        % 读取和处理掩膜TIFF文件
        tif_file = 'F:\pnf\clip2020pnf.tif';
        tif_data = imread(tif_file);
        
        % 创建掩膜，选择数值为 2 和 33 的区域
        mask = (tif_data == 33|tif_data == 2);
        %(tif_data == 2) | 

        % 只保留掩膜区域的数据
        masked_spei_values = spei_values(mask);
        
        % 计算掩膜区域内 spei 的平均值并累加
        current_month_mean = nanmean(masked_spei_values);

        % 清理 spei_values 变量以释放内存
        clear('spei_values');
        
        % 只有当平均值不是 NaN 时才累加
        if ~isnan(current_month_mean)
            spei_sum = spei_sum + current_month_mean;
            count = count + 1;
        end
    end
    
     % 计算每年的 spei 平均值
    if count > 0
        mean_spei(year_idx) = spei_sum / count;

    else
        mean_spei(year_idx) = NaN; % 如果某个年份没有任何有效数据，则设置为 NaN
    end
end

disp(nanmean(mean_spei))

% 绘制每年的 spei 平均值折线图
figure;
plot(years, mean_spei, 'o-');
xlabel('Year');
ylabel('Average spei');
title(['Yearly Average spei from ' num2str(years(1)) ' to ' num2str(years(end)) ]);
grid on;