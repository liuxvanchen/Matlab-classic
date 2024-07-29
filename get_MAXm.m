% 定义文件路径
filename = 'E:/test/spei03_cropped.nc';

% 使用ncread函数读取数据
spei = ncread(filename, 'spei');

% 计算最小值和最大值
min_value = min(spei(:));
max_value = max(spei(:));

% 显示结果
fprintf('spei 数据的最小值为: %f\n', min_value);
fprintf('spei 数据的最大值为: %f\n', max_value);
