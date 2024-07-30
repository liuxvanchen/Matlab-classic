clc;
clear;

%%
ncFilePath = 'E:\test\spei03.nc'; % 设定 NC 路径
ncdisp(ncFilePath); % 查看 NC 结构

% 读取第三个时间步的数据
timeStep = 3;
data3 = ncread(ncFilePath, 'spei', [1, 1, timeStep], [Inf, Inf, 1]);

% data3 现在包含第三个时间步的数据
data4=rot90(data3); %逆时针旋转90°

[A,R]=geotiffread("F:\SPEItxt\spei_Layer11.tif");%该处路径为上述Arcgis中导出带坐标系的TIFF文件**需要调整**
info=geotiffinfo("F:\SPEItxt\spei_Layer11.tif"); %该处路径为上述Arcgis中导出带坐标系的TIFF文件 **需要调整**

filename='F:\SPEItxt\output.tif'; %**需要调整**
geotiffwrite(filename,data4,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
