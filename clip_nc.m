clear;  % 清除变量
clc;    % 清屏

% 设置文件路径和文件名
ncFilePath = 'E:\test\spei03.nc';
shpFilePath = 'F:\clip_lai\shp\国界线84.shp';
newNcFilePath = 'E:\test\spei03_matlabclip.nc';


ncid = netcdf.open(ncFilePath, 'NOWRITE'); % 打开 NetCDF 文件

% 获取 NetCDF 文件中的所有变量名称
varNames = netcdf.inq(ncid);

% 获取变量名称数组
varNameArray = netcdf.inqVar(ncid,varNames);

% 关闭 NetCDF 文件
netcdf.close(ncid);

% 显示变量名称
disp('变量名称：');
for i = 1:length(varNameArray)
    disp(varNameArray(i).Name);
end

% 读取SHP文件
shpStruct = shaperead(shpFilePath);

% 获取SHP文件的边界坐标
shpLat = [shpStruct.Y];
shpLon = [shpStruct.X];

% 确定提取区域的经纬度范围
latRange = [min(shpLat), max(shpLat)];
lonRange = [min(shpLon), max(shpLon)];

% 打开原始NC文件以准备读取数据
ncid = netcdf.open(ncFilePath, 'NOWRITE');

% 读取NC文件中的经纬度和时间数据
latVarID = netcdf.inqVarID(ncid, 'lat');
lonVarID = netcdf.inqVarID(ncid, 'lon');
timeVarID = netcdf.inqVarID(ncid, 'time');
dataVarID = netcdf.inqVarID(ncid, 'data');

latData = netcdf.getVar(ncid, latVarID);
lonData = netcdf.getVar(ncid, lonVarID);
timeData = netcdf.getVar(ncid, timeVarID);

% 确定经纬度范围的索引
latIndices = find(latData >= latRange(1) & latData <= latRange(2));
lonIndices = find(lonData >= lonRange(1) & lonData <= lonRange(2));

% 创建新的NC文件来保存提取的数据
nccreate(newNcFilePath, 'data', 'Dimensions', {'lon', numel(lonIndices), 'lat', numel(latIndices), 'time', numel(timeData)}, 'Format', 'classic');
nccreate(newNcFilePath, 'lon', 'Dimensions', {'lon', numel(lonIndices)}, 'Format', 'classic');
nccreate(newNcFilePath, 'lat', 'Dimensions', {'lat', numel(latIndices)}, 'Format', 'classic');
nccreate(newNcFilePath, 'time', 'Dimensions', {'time', numel(timeData)}, 'Format', 'classic');

% 读取并写入数据
try
    % 读取数据
    ncData = netcdf.getVar(ncid, dataVarID, [lonIndices(1), latIndices(1), 1], [numel(lonIndices), numel(latIndices), numel(timeData)]);

    % 写入数据到新的NC文件
    ncwrite(newNcFilePath, 'data', ncData);
catch ME
    % 处理可能的错误
    disp(['发生错误: ' ME.message]);
end

% 关闭原始NC文件
netcdf.close(ncid);

% 显示保存成功消息
disp('数据已从NC文件中提取并保存为新的NC文件。');