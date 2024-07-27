% 替换为你的四个 HDF4 文件路径和数据集名称
filename1 = "E:\人工林数据\LAI\2020\GLASS01B01.V60.A2020249.2022138.hdf";
dataset_name1 = '/LAI';

filename2 = "E:\人工林数据\LAI\2020\GLASS01B01.V60.A2020257.2022138.hdf";
dataset_name2 = '/LAI';

filename3 = "E:\人工林数据\LAI\2020\GLASS01B01.V60.A2020265.2022138.hdf";
dataset_name3 = '/LAI';

%filename4 = "E:\人工林数据\LAI\2020\GLASS01B01.V50.A2020273.2021110.hdf";
%dataset_name4 = '/LAI';

% 使用 hdfread 函数读取每个 HDF4 文件的指定数据集
data1 = hdfread(filename1, dataset_name1);
data2 = hdfread(filename2, dataset_name2);
data3 = hdfread(filename3, dataset_name3);
%data4 = hdfread(filename4, dataset_name4);

% 假设四个数据集的数据是相同的大小和分辨率
% 获取数据集的大小（假设四个数据集的大小相同）
[rows, cols] = size(data1);

% 假设已经计算了 mean_data
%mean_data = (data1 + data2 + data3 +data4) / 4;
mean_data = (data1 + data2 + data3 ) / 3;

% 输出TXT (.txt) 文件路径
txt_filename = 'E:\人工林数据\txt\2020\mean_202009.txt';

% 打开TXT文件并写入头信息和数据
fid = fopen(txt_filename, 'w');
fprintf(fid, '%s\n', 'ncols         7200');
fprintf(fid, '%s\n', 'nrows         3600');
fprintf(fid, '%s\n', 'xllcorner     -180');
fprintf(fid, '%s\n', 'yllcorner     -90');
fprintf(fid, '%s\n', 'cellsize      0.05');
fprintf(fid, '%s\n', 'NODATA_value  -9999');

% 写入数据
for row = 1:size(mean_data, 1)
    fprintf(fid, '%f ', mean_data(row, :));
    fprintf(fid, '\n');
end

fclose(fid);

% 使用 gdal_translate 将TXT (.txt) 文件转换为 GeoTIFF (.tif) 文件（假设已安装GDAL）
tif_filename = 'E:\人工林数据\MeanLai\2020\mean_lai202009.tif';
system(['gdal_translate -of GTiff ' txt_filename ' ' tif_filename]);
