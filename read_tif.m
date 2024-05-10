% 假设文件名为 'example.tif'
filename = 'E:\Data-py\NDVI\clip-NDVI\2020-1.tif';

% 使用imfinfo获取文件信息
info = imfinfo(filename);

% 显示获取到的信息,其中-32768是无数值区域
disp(info);
imageData = imread(filename);
