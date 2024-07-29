% 定义文件路径  
filename = 'E:/test/spei03_cropped.nc';  
  
% 假设您想读取第10个时间点的数据（MATLAB索引从1开始）  
idx = 10;  
  
% 使用ncread函数读取指定时间索引下的spei数据  
% 注意：我们不需要为纬度和经度维度指定索引或步长，因为我们要读取整个切片  
%spei_at_time = ncread(filename, 'spei', idx, :, :);  
  
% 但是，由于ncread在较新版本的MATLAB中可能不直接支持这种语法，  
% 更通用的方法是使用netcdfinfo和ncvarget函数（需要NetCDF Toolbox）  
% 或者，如果ncread在您的MATLAB版本中有效，上面的行应该已经足够了  
% 如果ncread报错，请尝试以下方法：  
% 首先获取变量的维度信息  
info = netcdfinfo(filename);  
var = info.Variables('spei');  
  
% 然后使用ncvarget读取数据  
% 注意：这里我们不需要步长参数，只需指定要读取的起始索引和结束索引（对于整个维度，使用[])  
%spei_at_time = ncvarget(filename, var, [idx, 1, 1], [1, var.Dimensions(2), var.Dimensions(3)]);  
% 但实际上，对于整个切片，我们可以简化为：  
%spei_at_time = ncvarget(filename, 'spei', [idx, 1, 1], [1, Inf, Inf]);  
% 或者更简洁地（因为ncvarget可以处理整个维度）：  
spei_at_time = ncvarget(filename, 'spei', idx, :);  
  
% 此时，spei_at_time是一个二维矩阵，包含第idx个时间点的所有纬度和经度数据  
% 显示矩阵的大小以验证  
[lat_size, lon_size] = size(spei_at_time);  
fprintf('读取的SPEI数据矩阵大小为: %d x %d\n', lat_size, lon_size);