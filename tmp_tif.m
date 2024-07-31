clc;
clear;

%%
ncFilePath = "E:\人工林数据\降水1000\82-20\pre_1982.nc"; % 设定 NC 路径
ncdisp(ncFilePath); % 查看 NC 结构

% 读取第三个时间步的数据
timeStep = 1;
data3 = ncread(ncFilePath, 'pre', [1, 1, timeStep], [Inf, Inf, 1]);

% data3 现在包含第三个时间步的数据
data4=rot90(data3,3); %逆时针旋转90°
data5=fliplr(data4);

[A,R]=geotiffread("F:\pre_tmp_test\标准tif\pre_Layer11.tif");%该处路径为上述Arcgis中导出带坐标系的TIFF文件**需要调整**
info=geotiffinfo("F:\pre_tmp_test\标准tif\pre_Layer11.tif"); %该处路径为上述Arcgis中导出带坐标系的TIFF文件 **需要调整**

filename='F:\pre_tmp_test\output3.tif'; %**需要调整**
geotiffwrite(filename,data5,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
