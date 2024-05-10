filename = 'E:\Data-py\NDVI\2020-5ndvihdf\MOD13A3.A2020122.h26v04.061.2020335213015.hdf';
info = hdfinfo(filename);

% 显示获取到的信息
disp(info);

globalAttributes = info.Attributes;
disp('Global Attributes:');
disp(globalAttributes);

% 读取“1 km monthly NDVI”数据集
ndviData = hdfread(filename, '1 km monthly NDVI', 'Fields', 'fieldname', 'Index', {[] [] []});

% 显示数据
disp(ndviData);
