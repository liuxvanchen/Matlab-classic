% 指定NetCDF文件名
filename = 'D:\Python\data\clip_nc.nc';

% 读取时间变量（假设时间变量名为'time'）
time = ncread(filename, 'time');

% 读取tp变量
water = ncread(filename, 'tp');

% 时间长度能够被12整除，没有不完整的年份
num_months = length(time);  % 这里改为总月数

% 初始化数组以存储每个月的总和
monthly_sum_tp = zeros(num_months, 1);

% 循环每个月计算总和，忽略 NaN 值
for i = 1:num_months
    % 提取每个月的数据
    current_month_tp = water(:, :, i);

    % 计算每个月的总和，忽略 NaN
    monthly_total = nansum(current_month_tp, 'all');
    
    % 获取当前月份的天数
    % 假设时间从1982年1月开始，根据时间索引计算年份和月份
    year = 1982 + floor((i-1) / 12);
    month = mod(i-1, 12) + 1;
    days_in_month = eomday(year, month);
    
    % 将每月总和乘以天数
    monthly_sum_tp(i) = monthly_total * days_in_month;
end

% 显示每月总和
disp(monthly_sum_tp);
