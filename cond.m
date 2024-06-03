% 引入符号计算功能
syms a;

% 定义矩阵，包含符号变量a
A = [2*a, a, 0; 0, a, 0; 0, 0, a];

% 检查矩阵是否奇异，如果不是，则计算逆矩阵
if det(A) ~= 0
    A_inv = inv(A);
else
    error('Matrix is singular, inverse does not exist.');
end

% 计算矩阵和其逆矩阵的无穷范数
norm_A = norm(A, 'inf');
norm_A_inv = norm(A_inv, 'inf');

% 计算条件数
condition_number = norm_A * norm_A_inv;

% 显示条件数表达式
fprintf('条件数表达式（无穷范数）：%s\n', char(condition_number));
