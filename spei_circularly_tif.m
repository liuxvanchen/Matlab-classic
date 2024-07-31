clc;
clear;

% 设定 NC 文件路径
ncFilePath = "F:\newspei03.nc";

% 读取 SPEI 变量的维度信息
lon = ncread(ncFilePath, 'lon');
lat = ncread(ncFilePath, 'lat');
time = ncread(ncFilePath, 'time');

% 如果 TIFF 文件夹不存在，则创建
tifFolder = 'F:\Spei_tif';
if ~exist(tifFolder, 'dir')
    mkdir(tifFolder);
end

% 循环处理每个时间步（假设时间步对应每个月）
for t = 13:length(time)
    % 读取当前时间步的 SPEI 数据
    data = ncread(ncFilePath, 'spei', [1, 1, t], [Inf, Inf, 1]);
    
    % 旋转和翻转数据（与您原始脚本相同）
    dataRotated = rot90(data);
    dataFlipped = flipud(dataRotated);
    
    % 确定用于命名 TIFF 文件的年份和月份
    % 第13个时间步对应1982年1月，依次类推
    year = floor((1982 + (t - 13) / 12));
    month = mod(t - 1, 12) + 1;
    
    % 如果当前年份的文件夹不存在，则创建
    yearFolder = fullfile(tifFolder, num2str(year));
    if ~exist(yearFolder, 'dir')
        mkdir(yearFolder);
    end
    
    % 构造 TIFF 文件名
    filename = fullfile(yearFolder, sprintf('spei_%d_%02d.tif', year, month));
    
    % 从示例 TIFF 文件中读取地理信息（根据需要调整路径）
    [~, sampleR] = geotiffread("F:\SPEItxt\spei标准\spei_Layer21.tif");
    sampleInfo = geotiffinfo("F:\SPEItxt\spei标准\spei_Layer21.tif");
    
    % 将当前月份的数据写入 GeoTIFF 文件
    geotiffwrite(filename, dataFlipped, sampleR, 'GeoKeyDirectoryTag', sampleInfo.GeoTIFFTags.GeoKeyDirectoryTag);
    
    fprintf('已处理并保存：%s\n', filename);
end
