% 定义NetCDF文件名和路径
filename = 'D:\Python\pythonProject1\论文\降水气温辐射处理\download.nc';

% 从NetCDF文件读取时间变量，单位为小时
time_hours = ncread(filename, 'time');

% 定义起始日期
start_date = datetime('1900-01-01 00:00:00');

% 将小时数转换为天数
time_days = time_hours / 24;

% 计算实际日期
actual_dates = start_date + days(time_days);

% 格式化日期为年-月
formatted_dates = datestr(actual_dates, 'yyyy-mm');

% 显示格式化后的日期
disp(formatted_dates);


