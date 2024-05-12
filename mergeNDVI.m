% 确定覆盖中国的瓦片范围
h_start = 21; h_end = 30;  % 水平瓦片号从21到30
v_start = 3; v_end = 7;    % 垂直瓦片号从3到7

% 创建一个数组，大小根据中国覆盖的瓦片范围来确定
tile_width = 1200;  % 每个瓦片的尺寸
tile_height = 1200;
width = (h_end - h_start + 1) * tile_width;
height = (v_end - v_start + 1) * tile_height;
all_ndvi_data = NaN(height, width);  % 初始化数组，填充为NaN

% 设置包含HDF文件的目录
directory = 'E:\Data-py\NDVI\2020-2ndvihdf';

% 获取目录中所有文件
files = dir(fullfile(directory, '*.hdf'));

% 遍历所有文件
for i = 1:length(files)
    filename = files(i).name;
    % 解析文件名中的瓦片编号
    tokens = regexp(filename, 'h(\d+)v(\d+)', 'tokens');
    if ~isempty(tokens)
        h_tile = str2double(tokens{1}{1});
        v_tile = str2double(tokens{1}{2});
        
        if h_start <= h_tile && h_tile <= h_end && v_start <= v_tile && v_tile <= v_end
            h_offset = (h_tile - h_start) * tile_width;
            v_offset = (v_tile - v_start) * tile_height;

            file_path = fullfile(directory, filename);
            hdf = hdfread(file_path, '1 km monthly EVI', 'Fields', '1 km monthly EVI');
            ndvi_data = double(hdf) * 0.0001;

            % 将数据放到正确的位置
            all_ndvi_data(v_offset+1:v_offset+tile_height, h_offset+1:h_offset+tile_width) = ndvi_data;
        end
    end
end

% 指定输出文件路径和名称
outputTiffFile = fullfile(directory, 'MergedNDVI2020-2.tif');

% 写入数据到GeoTIFF文件
geotiffwrite(outputTiffFile, all_ndvi_data);
