% 输入文件夹和输出文件夹
inputFolder = 'E:\人工林数据\MeanLai2\2001';  % 替换为你的输入文件夹路径
outputFolder ="F:\clip_lai2\2001";  % 替换为你的输出文件夹路径

% Shapefile路径
shapefile = 'F:\clip_lai\shp';  % 替换为你的Shapefile路径

% 循环处理每个TIFF文件
files = dir(fullfile(inputFolder, '*.tif'));
for i = 1:length(files)
    inputTiff = fullfile(inputFolder, files(i).name);
    outputTiff = fullfile(outputFolder, files(i).name);
    
    % 设置裁剪参数
    command = sprintf('gdalwarp -cutline %s -crop_to_cutline %s %s', shapefile, inputTiff, outputTiff);
    system(command);
end

disp('裁剪完成！');
