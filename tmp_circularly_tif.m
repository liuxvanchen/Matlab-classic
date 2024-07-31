clc;
clear;

% 定义路径
ncRootPath = 'E:\人工林数据\降水1000\82-20'; % NC文件的根目录
outputRootPath = 'F:\Pre'; % 输出文件的根目录

% 循环处理每一年的数据
for year = 1982:2020
    % 构建当前年份的NC文件路径
    ncFileName = sprintf('pre_%d.nc', year);
    ncFilePath = fullfile(ncRootPath, ncFileName);
    
    % 检查当前年份的输出目录是否存在，不存在则创建
    outputYearPath = fullfile(outputRootPath, num2str(year));
    if ~exist(outputYearPath, 'dir')
        mkdir(outputYearPath);
    end
    
    % 循环处理每个月份的数据（假设有12个月）
    for month = 1:12
        % 读取当前月份的数据
        data = ncread(ncFilePath, 'pre', [1, 1, month], [Inf, Inf, 1]);
        
        % 旋转和翻转数据（按照原始处理方法）
        data = rot90(data, 3);
        data = fliplr(data);
        
        % 构建当前月份的输出文件路径
        outputFileName = sprintf('pre_%d_%02d.tif', year, month);
        outputFilePath = fullfile(outputYearPath, outputFileName);
        
        % 读取参考Geotiff文件以获取地理参考信息
        [A, R] = geotiffread("F:\pre_tmp_test\标准tif\pre_Layer11.tif");
        info = geotiffinfo("F:\pre_tmp_test\标准tif\pre_Layer11.tif");
        
        % 将处理后的数据写入Geotiff文件
        geotiffwrite(outputFilePath, data, R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
        
        % 显示处理进度
        fprintf('已处理并保存：%s\n', outputFilePath);
    end
end

fprintf('所有数据处理和保存完成。\n');
