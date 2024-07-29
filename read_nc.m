% 定义文件路径
nc_file = 'E:/test/spei03.nc';

% 打开 NetCDF 文件
ncid = netcdf.open(nc_file, 'NC_NOWRITE');

% 获取变量ID
spei_varid = netcdf.inqVarID(ncid, 'spei');

% 获取变量的信息
[varname, xtype, dimids, numatts] = netcdf.inqVar(ncid, spei_varid);

% 获取每个维度的长度
dim_lengths = zeros(1, length(dimids));
for k = 1:length(dimids)
    [dimname, dimlen] = netcdf.inqDim(ncid, dimids(k));
    dim_lengths(k) = dimlen;
end

% 确认文件中至少有三个时间步
if dim_lengths(1) < 3
    error('NetCDF 文件中少于 3 个时间步');
end

% 读取第三个时间步的数据
start = [2, 0, 0]; % 起始索引，从 0 开始计数
count = [1, dim_lengths(2), dim_lengths(3)]; % 读取一个时间步的所有数据
spei_data = netcdf.getVar(ncid, spei_varid, start, count);

% 获取 _FillValue 属性
fill_value = netcdf.getAtt(ncid, spei_varid, '_FillValue');

% 将 _FillValue 替换为 NaN
spei_data = double(spei_data); % 确保数据是 double 类型
spei_data(spei_data == fill_value) = NaN;

% 移除时间维度并重塑数据为 (7200, 2000)
spei_matrix = squeeze(spei_data);
spei_matrix = spei_matrix';

% 关闭 NetCDF 文件
netcdf.close(ncid);

% 显示第三个时间步数据的统计信息
disp('第三个时间步 spei 数据的统计信息：');
disp(['最小值: ', num2str(min(spei_matrix(:)))]);
disp(['最大值: ', num2str(max(spei_matrix(:)))]);
disp(['平均值: ', num2str(mean(spei_matrix(:), 'omitnan'))]);
disp(['标准差: ', num2str(std(spei_matrix(:), 'omitnan'))]);