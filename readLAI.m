% 替换为你的 HDF 文件路径
filename = "E:\人工林数据\LAI\2000\GLASS01B02.V40.A2000353.2019353.hdf";
%testdata_set = '/LAI';

%read=hdfread(filename,testdata_set);

% 使用 hdfinfo 函数读取 HDF4 文件信息
info = hdfinfo(filename);

% 显示文件信息
disp(['HDF 文件信息：', filename]);
disp('-----------------------------');

% 显示全局属性信息（如果有的话）
global_attributes = info.Attributes;
if ~isempty(global_attributes)
    disp('全局属性信息:');
    for i = 1:length(global_attributes)
        attr_name = global_attributes(i).Name;
        attr_value = global_attributes(i).Value;
        fprintf('%s: %s\n', attr_name, attr_value);
    end
else
    disp('没有找到全局属性信息。');
end
disp('-----------------------------');

% 显示数据集信息
datasets = info.SDS;
if ~isempty(datasets)
    disp('数据集信息:');
    for i = 1:length(datasets)
        dataset_name = datasets(i).Name;
        dataset_attributes = datasets(i).Attributes;
        
        % 显示数据集名称
        fprintf('数据集名称: %s\n', dataset_name);
        
        % 显示数据集属性信息（如果有的话）
        if ~isempty(dataset_attributes)
            disp('数据集属性:');
            for j = 1:length(dataset_attributes)
                attr_name = dataset_attributes(j).Name;
                attr_value = dataset_attributes(j).Value;
                fprintf('%s: %s\n', attr_name, attr_value);
            end
        else
            disp('没有找到数据集属性信息。');
        end
        
        % 显示数据集维度信息
        dataset_dims = datasets(i).Dims;
        disp('数据集维度:');
        disp(dataset_dims);
        
        disp('-----------------------------');
    end
else
    disp('没有找到数据集信息。');
end
