% 指定文件路径
filename = 'D:\Python\pythonProject1\论文\降水气温辐射处理\download.nc';
%D:\Python\data\clip_nc.nc

% 指定你想读取的变量名
varname = 'tp';  

% 读取变量
%data = ncread(filename, varname);

% 显示数据
%disp(data)

% 查看NetCDF文件的所有信息
info = ncinfo('D:\Python\pythonProject1\论文\降水气温辐射处理\download.nc');
disp(info);
% 读取变量的单位属性
unit = ncreadatt('D:\Python\pythonProject1\论文\降水气温辐射处理\download.nc', 'tp', 'units');
disp(['Unit: ', unit]);

