% 输入文件和输出文件夹路径
inputFile = 'E:\test\spei03.nc';  % NetCDF文件路径
outputFolder = 'F:\MeanSPEI\1982';  % 输出文件夹路径

% 打开NetCDF文件
ncid = netcdf.open(inputFile, 'NOWRITE');

% 获取变量信息
lon = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon'));  % 经度
lat = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat'));  % 纬度
time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));  % 时间
spei_varid = netcdf.inqVarID(ncid, 'spei');  % SPEI数据变量ID

% 确定处理的年份（这里示例处理1982年的数据）
year = 1982;

% 使用datevec获取年份信息
time_datevec = datevec(time);

% 创建输出文件夹
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% 循环处理每个月的数据
for month = 1:12
    % 计算当前月的时间索引
    month_indices = find(time_datevec(:, 1) == year & time_datevec(:, 2) == month);

    % 打印月份索引，确保它们在合理范围内
    disp(month_indices);

        % 调整读取SPEI数据的代码
    if ~isempty(month_indices)
        % 计算当前月每个像元的平均值
        month_data = netcdf.getVar(ncid, spei_varid, [0, 0, month_indices(1)-1], [Inf, Inf, length(month_indices)]);
         % 计算当前月每个像元的平均值
    monthly_average = mean(month_data, 3, 'omitnan');  % 按第三个维度（时间步）求平均值

    % 转置以匹配MATLAB绘图习惯（经度在x轴，纬度在y轴）
    monthly_average = squeeze(monthly_average)';

    % 生成输出文件名和路径
    output_file_name = sprintf('Mean_SPEI_%d_%02d.tif', year, month);
    output_file_path = fullfile(outputFolder, output_file_name);

    % 写入TIFF文件
    geotiffwrite(output_file_path, monthly_average, lon, lat, 'CoordRefSysCode', 4326);

    fprintf('已保存 %s\n', output_file_path);
    end
    
    disp('所有月平均值TIFF文件生成完成！');
    
    % 关闭NetCDF文件
    netcdf.close(ncid);
       
    else
        fprintf('错误：未找到时间步索引。\n');
    end
    % 提取当前月的数据
    month_data = netcdf.getVar(ncid, spei_varid, [0, 0, month_indices(1)-1], [Inf, Inf, length(month_indices)]);

   
