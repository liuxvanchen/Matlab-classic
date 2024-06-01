filename = "E:\浏览器下载\GEE\MODIS_NDVI_2017-01-01.tif";

% 使用imfinfo获取文件信息
info = imfinfo(filename);

% 显示获取到的信息,其中-32768是无数值区域
disp(info);
imageData = imread(filename);
