filename = 'E:\Data-py\NDVI\2020-5ndvihdf\MOD13A3.A2020122.h26v04.061.2020335213015.hdf';
info = hdfinfo(filename);

% 显示获取到的信息
disp(info);

% 获取Vgroup信息
vgroup = info.Vgroup;

% 显示Vgroup的字段
disp(fieldnames(vgroup));

% 获取SDS字段
sds_info = info.Vgroup.Vgroup.SDS;

% 遍历SDS数组，显示每个SDS数据集的名称
for i = 1:length(sds_info)
    disp(['数据集名称: ', sds_info(i).Name]);
end


% 读取“1 km monthly NDVI”数据集
%ndviData = hdfread(filename, '1 km monthly NDVI', 'Fields', 'fieldname', 'Index', {[] [] []});

% 显示数据
%disp(ndviData);

data = hdfread(filename, '1 km monthly NDVI', 'Fields', 'fieldname');
numDims = ndims(data);
disp(['数据的维度数量: ', num2str(numDims)]);
