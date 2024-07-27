% 主脚本 main_lai.m

% 定义要执行的脚本文件名
lais = {'laimean.m', 'lai2.m', 'lai3.m', 'lai4.m', ...
           'lai5.m', 'lai6.m', 'lai7.m', 'lai8.m', ...
           'lai9.m', 'lai10.m', 'lai11.m', 'lai12.m'};

% 循环执行每个脚本文件
for i = 1:numel(lais)
    fprintf('Running %s...\n', lais{i});
    run(lais{i});
end

disp('All 2018lais executed.');
