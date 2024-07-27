% 指定NetCDF文件的路径
filename = 'E:\人工林数据\气温1000\82-20\tmp_1982.nc';

% 打开NetCDF文件
ncid = netcdf.open(filename, 'NC_NOWRITE');

% 获取变量ID
time_id = netcdf.inqVarID(ncid, 'time');
lat_id = netcdf.inqVarID(ncid, 'lat');
lon_id = netcdf.inqVarID(ncid, 'lon');
tmn_id = netcdf.inqVarID(ncid, 'tmp');

% 获取维度信息
[lat_dim_id, lat_length] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'lat'));
[lon_dim_id, lon_length] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'lon'));

% 读取数据
time = netcdf.getVar(ncid, time_id);
latitudes = netcdf.getVar(ncid, lat_id);
longitudes = netcdf.getVar(ncid, lon_id);

% 假设1988年1月对应的索引为1（MATLAB索引从1开始）
jan_1982_index = 1;

% 根据维度读取1988年1月的气温数据
tmn_jan_1982 = netcdf.getVar(ncid, tmn_id, [0, 0, jan_1982_index-1], [lon_length, lat_length, 1]);

% 关闭NetCDF文件
netcdf.close(ncid);

% 处理和显示数据
tmn_jan_1982 = double(tmn_jan_1982) * 0.1;  % 转换为正常温度值，原始数据以0.1度为单位存储
disp(tmn_jan_1982);

max_value = max(tmn_jan_1982(:)); % 将矩阵展开为向量并找到最大值
disp(['矩阵的最大值是：', num2str(max_value)]);
