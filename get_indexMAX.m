clc;
clear;

% 设定 NC 文件路径
ncFilePath = 'E:\test\spei03.nc';

% 查看 NC 文件结构
ncdisp(ncFilePath);

% 定义切片的索引
lon_idx = 1:7200; % 所有经度
lat_idx = 1:2000; % 所有纬度
time_idx = 3;     % 第三个时间序列

% 定义数据块大小
chunk_lon = 1000; % 经度分块大小
chunk_lat = 500;  % 纬度分块大小

% 预分配数据矩阵
data3 = nan(2000, 7200); % 注意调整为2000行 x 7200列

% 逐块读取数据
for i = 1:ceil(7200 / chunk_lon)
    lon_start = (i - 1) * chunk_lon + 1;
    lon_end = min(i * chunk_lon, 7200);
    
    for j = 1:ceil(2000 / chunk_lat)
        lat_start = (j - 1) * chunk_lat + 1;
        lat_end = min(j * chunk_lat, 2000);
        
        % 读取数据块
        data_chunk = ncread(ncFilePath, 'spei', [lon_start, lat_start, time_idx], [lon_end - lon_start + 1, lat_end - lat_start + 1, 1], [1, 1, 1]);
        
        % 处理 NaN 值为 2000
        data_chunk(isnan(data_chunk)) = 100;
        
        % 将数据块赋值到正确的位置
        data3(lat_start:lat_end, lon_start:lon_end) = permute(data_chunk, [2, 1]); % 注意这里的位置调整
    end
end

% 将所有值为 0.000306 的元素替换为 100

% 假设已经有 data3 和 txt_filename 的定义
[rows, cols] = size(data3);

% 输出TXT (.txt) 文件路径
txt_filename = 'F:\SPEItxt\test10.txt';

% 打开TXT文件并写入头信息和数据
fid = fopen(txt_filename, 'w');
fprintf(fid, '%s\n', 'ncols         7200');
fprintf(fid, '%s\n', 'nrows         2000');
fprintf(fid, '%s\n', 'xllcorner     -180');
fprintf(fid, '%s\n', 'yllcorner     -50');
fprintf(fid, '%s\n', 'cellsize      0.05');
fprintf(fid, '%s\n', 'NODATA_value  -9999');

% 写入数据
for row = 1:size(data3, 1)
    fprintf(fid, '%f ', data3(row, :));
    fprintf(fid, '\n');
end

fclose(fid);

% 使用 gdal_translate 将TXT (.txt) 文件转换为 GeoTIFF (.tif) 文件（假设已安装GDAL）
tif_filename = 'F:\SPEItxt\test10.tif';
system(['gdal_translate -of GTiff ' txt_filename ' ' tif_filename]);
