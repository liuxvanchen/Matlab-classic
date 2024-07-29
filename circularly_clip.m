% 输入文件夹和输出文件夹的根路径
inputRootFolder = 'E:\人工林数据\MeanLai';  % 输入文件夹的根路径
outputRootFolder = 'F:\clip_lai';  % 输出文件夹的根路径

% 循环处理每一年的文件夹
for year = 1982:2019
    % 构造当前年份的文件夹路径
    inputFolder = fullfile(inputRootFolder, num2str(year));
    outputFolder = fullfile(outputRootFolder, num2str(year));
    
    % 创建输出文件夹（如果不存在）
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % Shapefile路径
    shapefile = 'F:\clip_lai\shp';  % 替换为你的Shapefile路径
    
    % 获取当前年份文件夹中所有的TIFF文件列表
    files = dir(fullfile(inputFolder, '*.tif'));
    
    % 循环处理每个TIFF文件
    for i = 1:length(files)
        inputTiff = fullfile(inputFolder, files(i).name);
        outputTiff = fullfile(outputFolder, files(i).name);
        
        % 设置裁剪参数
        command = sprintf('gdalwarp -cutline "%s" -crop_to_cutline "%s" "%s"', shapefile, inputTiff, outputTiff);
        system(command);
    end
    
    disp(['完成年份 ' num2str(year) ' 的裁剪！']);
end

disp('所有年份的裁剪完成！');
