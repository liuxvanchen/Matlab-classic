function [h, p] = mk_test(x)
    % Mann-Kendall 检验
    % 输入：
    %   x - 时间序列数据
    % 输出：
    %   h - 0 表示无显著趋势，1 表示有显著趋势
    %   p - p值，用于确定趋势的显著性
    
    % 去除 NaN 数据
    x = x(~isnan(x));
    
    n = length(x);
    
    % 如果数据点少于两点，无法进行检验
    if n < 2
        h = NaN;
        p = NaN;
        return;
    end
    
    % 计算 Mann-Kendall S 统计量
    S = 0;
    for i = 1:n-1
        for j = i+1:n
            S = S + sign(x(j) - x(i));
        end
    end
    
    % 计算方差
    var_S = (n * (n - 1) * (2 * n + 5)) / 18;
    
    % 计算 Z 统计量
    if S > 0
        Z = (S - 1) / sqrt(var_S);
    elseif S < 0
        Z = (S + 1) / sqrt(var_S);
    else
        Z = 0;
    end
    
    % 计算 p 值
    p = 2 * (1 - normcdf(abs(Z)));
    
    % 显著性水平（例如 0.05）
    alpha = 0.05;
    
    % h = 1 表示有显著趋势，h = 0 表示无显著趋势
    h = abs(Z) > norminv(1 - alpha / 2);
end
