clc;
clear;

%%
ncFilePath = "F:\newspei03.nc"; % 设定 NC 路径
ncdisp(ncFilePath); % 查看 NC 结构

% 读取第三个时间步的数据
timeStep = 13;
data3 = ncread(ncFilePath, 'spei', [1, 1, timeStep], [Inf, Inf, 1]);

% data3 现在包含第三个时间步的数据
data4=rot90(data3); %逆时针旋转90°
data5=flipud(data4);

[A,R]=geotiffread("F:\SPEItxt\spei标准\spei_Layer21.tif");%该处路径为上述Arcgis中导出带坐标系的TIFF文件**需要调整**
info=geotiffinfo("F:\SPEItxt\spei标准\spei_Layer21.tif"); %该处路径为上述Arcgis中导出带坐标系的TIFF文件 **需要调整**

filename='F:\SPEItxt\newoutput.tif'; %**需要调整**
geotiffwrite(filename,data5,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
