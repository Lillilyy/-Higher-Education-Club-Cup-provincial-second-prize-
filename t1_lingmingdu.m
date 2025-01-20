% 第一问灵敏度分析代码：
% 探究不同次品率下所需要的最小样本量，次品率变化范围0.01~0.2，步长为0.01
% 计算灵敏度，即在所有实际为阳性的样本中，被正确识别为阳性的比例

clc;
clear;
% 计算样本量n在不同信度下的值
% 输入参数
p0_range = linspace(0.01, 0.2, 19);  % 标称次品率范围
epsilon = 0.05;  % 允许误差

% Z 值（正态分布临界值对应 95% 和 90% 的信度）
Z_95 = 1.645;  % 对应 95% 信度的 Z 值
Z_90 = 1.28;   % 对应 90% 信度的 Z 值

% 初始化结果数组
n_95_array = zeros(size(p0_range));
n_90_array = zeros(size(p0_range));

% 遍历不同的标称次品率，计算对应的最小样本量
for i = 1:length(p0_range)
    p0 = p0_range(i);
    n_95_array(i) = (Z_95^2 * p0 * (1 - p0)) / (epsilon^2);
    n_90_array(i) = (Z_90^2 * p0 * (1 - p0)) / (epsilon^2);
    n_95_array(i) = ceil(n_95_array(i));
    n_90_array(i) = ceil(n_90_array(i));
end

% 计算灵敏度指标
sensitivity_95 = n_95_array ./ (n_95_array + n_90_array);
sensitivity_90 = n_90_array ./ (n_95_array + n_90_array);

% 可视化结果
figure;
plot(p0_range, sensitivity_95, 'k-', 'LineWidth', 1);
hold on;
plot(p0_range, sensitivity_90, 'r--', 'LineWidth', 2);
xlabel('标称次品率');
ylabel('灵敏度');
legend('95% 置信水平', '90% 置信水平');
grid on;

% 可视化最小样本量
figure;
plot(p0_range, n_95_array, 'k-', 'LineWidth', 1);
hold on;
plot(p0_range, n_90_array, 'r--', 'LineWidth', 2);
xlabel('标称次品率');
ylabel('最小样本量');
legend('95% 置信水平', '90% 置信水平');
grid on;

