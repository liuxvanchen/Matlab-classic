% 指定NetCDF文件名
filename = 'D:\Python\data\clip_nc.nc';

% 读取时间变量（假设时间变量名为'time'）
time = ncread(filename, 'time');

% 读取tp变量
water = ncread(filename, 'tp');

% 检查数据中的每个元素是否为NaN
isnan_array = isnan(water);

% 计算非NaN的数据个数
num_non_nan = sum(~isnan_array(:));  % 将逻辑数组转换为列向量并求和
num_nan=num_non_nan/468;

% 时间长度能够被12整除，没有不完整的年份
num_years = 2020 - 1982 + 1;  % 从1982年到2020年
num_months_per_year = 12;  % 每年12个月
num_months = num_years * num_months_per_year;  % 总月数

% 初始化每月总和数组
monthly_sum_tp = zeros(1, num_months);

% 循环每年每月计算总和，忽略NaN值
for year_idx = 1:num_years
    for month_idx = 1:num_months_per_year
        absolute_month_idx = (year_idx - 1) * num_months_per_year + month_idx;

        % 提取每个月的数据
        current_month_tp = water(:, :, absolute_month_idx);

        % 计算每个月的总和，忽略NaN
        monthly_total = nansum(current_month_tp, 'all');

        % 计算年份和月份
        current_year = 1982 + year_idx - 1;
        current_month = month_idx;
        days_in_month = eomday(current_year, current_month);

        % 将每月总和乘以天数
        monthly_sum_tp(absolute_month_idx) = monthly_total * days_in_month;
    end
end

% 计算每年的总和
annual_sum_tp = zeros(1, num_years);
for year_idx = 1:num_years
    idx_start = (year_idx - 1) * num_months_per_year + 1;
    idx_end = year_idx * num_months_per_year;

    % 计算每年的总和
    annual_sum_tp(year_idx) = (sum(monthly_sum_tp(idx_start:idx_end)))/num_nan*1000;
end



years = (1982:2020);  % 假设数据从1982年开始到2020年

% 创建一个折线图显示每年的总降水量
figure;
plot(years, annual_sum_tp, '-o');
title('Annual Total Precipitation');
xlabel('Year');
ylabel('Total Precipitation(mm)');
grid on;
