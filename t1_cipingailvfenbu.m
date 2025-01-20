% 第一问绘图代码：
% 在95%信度下，最小样本量为98时的，次品概率分布情况，最高点时的Y=13.1557
% 在90%信度下，最小样本量为59时的，次品概率分布情况，最高点时的Y=10.1686

clc;
clear;
% 设置中文字体
set(0, 'DefaultAxesFontName', 'SimHei');  % 用黑体显示中文
set(0, 'DefaultTextFontName', 'SimHei');
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 12);

% 定义参数
p0 = 0.10;  % 标称次品率
n_95 = 98;  % 95%信度下的样本量
n_90 = 59;  % 90%信度下的样本量
Z_95 = 1.645;  % 对应95%信度的Z值
Z_90 = 1.28;  % 对应90%信度的Z值

% 计算拒绝域的上下限
x_95 = p0 + Z_95 * sqrt(p0 * (1 - p0) / n_95);
x_90 = p0 + Z_90 * sqrt(p0 * (1 - p0) / n_90);

% 生成x轴样本点（次品率范围）
x = linspace(0, 0.2, 1000);

% 正态分布概率密度函数
pdf_95 = normpdf(x, p0, sqrt(p0 * (1 - p0) / n_95));
pdf_90 = normpdf(x, p0, sqrt(p0 * (1 - p0) / n_90));

% 绘图
figure;
hold on;

% 绘制 95% 信度下的概率分布曲线
plot(x, pdf_95, 'k', 'DisplayName', '95% 置信水平');

% 绘制 90% 信度下的概率分布曲线
plot(x, pdf_90, 'k--', 'DisplayName', '90% 置信水平');

fill([x_95, x(x > x_95), 0.2], [0, pdf_95(x > x_95), 0], 'b', 'FaceAlpha', 0.3, 'DisplayName', '95% 拒绝区域');
fill([0, x(x < x_90), x_90], [0, pdf_90(x < x_90), 0], 'r', 'FaceAlpha', 0.3, 'DisplayName', '90% 接收区域');

% 绘制标称次品率 p0 的垂直线
xline(p0, 'k--', 'DisplayName', sprintf('标称次品率 p0 = %.2f', p0));

% 图例
legend('Location', 'best');

% 标题和标签
xlabel('次品率 (p)');
ylabel('概率密度');

% 显示图像
grid on;
hold off;

