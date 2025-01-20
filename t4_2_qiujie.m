%% 代码说明
% 求解第四问-问题三情况下的代码
% 训练鲸鱼算法
% 鲸鱼数量：10
% 最大迭代数为：50
% 决策变量的纬度为：4
%% 主程序
clc
clear
jingyushu = 10;  % 鲸鱼数量
MAXGEN = 100;    % 最大迭代次数
weidu = 16;      % 决策变量的维度
ub = 1 * ones(1, weidu);  % 决策变量的上界
lb = 0 * ones(1, weidu);  % 决策变量的下界
L_p = zeros(1, weidu);    % 最优解的位置
id = 1;                    % 情况编号
L_s = inf;                 % 最优解的适应度值
PS = rand(jingyushu, weidu) .* repmat(ub - lb, jingyushu, 1) + repmat(lb, jingyushu, 1);  % 初始化鲸鱼位置
trace = zeros(1, MAXGEN);  % 记录每一代的最优适应度值

% 定义 n 的范围
n_values = 100:100:1000;

% 初始化结果表格
results = cell(length(n_values), 19);
row_index = 1;

for n = n_values
    % 重置最优解
    L_p = zeros(1, weidu);
    L_s = inf;
    
    for kk = 1:MAXGEN
        % 更新参数
        a = 2 - kk * (2 / MAXGEN);  % 线性递减的参数a
        a2 = -1 + kk * (1 / MAXGEN);  % 线性递减的参数a2
        
        for i = 1:jingyushu
            % 边界处理：越界赋值为边界值
            ubb = PS(i, :) > ub;
            lbb = PS(i, :) < lb;
            PS(i, :) = (PS(i, :).*(~(ubb + lbb))) + ub.*ubb + lb.*lbb;
            
            % 计算适应度值
            fitness = ObjFun(PS(i, :), id, n);
            
            % 更新最优解
            if fitness < L_s
                L_s = fitness;
                L_p = PS(i, :);
            end
        end
        
        % 更新鲸鱼位置
        for i = 1:jingyushu
            r1 = rand(); r2 = rand();
            A = 2 * a * r1 - a;  % 参数A
            C = 2 * r2;          % 参数C
            b = 1;               % 螺旋参数
            l = (a2 - 1) * rand() + 1;  % 螺旋参数
            p = rand();          % 随机选择更新方式
            
            for j = 1:weidu
                if p < 0.5  % 包围捕食
                    if abs(A) < 1
                        D = abs(C * L_p(j) - PS(i, j));
                        PS(i, j) = L_p(j) - A * D;
                    else
                        rand_leader_index = floor(jingyushu * rand() + 1);
                        X_rand = PS(rand_leader_index, :);
                        D_X_rand = abs(C * X_rand(j) - PS(i, j));
                        PS(i, j) = X_rand(j) - A * D_X_rand;
                    end
                else  % 螺旋更新
                    distance_Leader = abs(L_p(j) - PS(i, j));
                    PS(i, j) = distance_Leader * exp(b * l) * cos(l * 2 * pi) + L_p(j);
                end
            end
        end
        
        % 记录当前代的最优适应度值
        trace(kk) = L_s;
    end
    
    % 结果输出
    name = ["零件1检测率", "零件2检测率", "零件3检测率", "零件4检测率", "零件5检测率", "零件6检测率", "零件7检测率", "零件8检测率", "半成品1检测率", "半成品2检测率", "半成品3检测率", "半成品1拆解率", "半成品2拆解率", "半成品3拆解率", "成品检测率", "成品拆解率"];
    [ans1, ans2] = ObjFun1(L_p, id, n);
    
    % 保存结果到表格
    results{row_index, 1} = n;
    for col_index = 1:16
        results{row_index, col_index + 1} = L_p(col_index);
    end
    results{row_index, 18} = ans1;
    results{row_index, 19} = ans2 * 200;
    
    row_index = row_index + 1;
end

% 显示结果表格
results_table = cell2table(results, 'VariableNames', ['n', name, '成本', '收入']);
disp(results_table);

%% 模拟题目中的步骤1、2
function [mon, inco] = ObjFun1(ttt, id, n)
    inco = 0;
    mon = 0;
    ma1 = [0.11538 2 1; 0.21154 8 1; 0.17308 12 2; 0.076923 2 1; 0.15385 8 1; 0.057692  12 2; 0.13462 8 1; 0.096154 12 2];
    ma2 = [0.13462 8 4 6; 0.19231 8 4 6; 0.11538 8 4 6];
    ma3 = [0.15385 8 6 10];
    for zzz = 1:2
        H = [1000 1000 1000];
        D = 1000;
        beta = 0;
        for i = 1:8
            mon = mon + ma1(i, 2) * ma1(i, 3) + ttt(i) * ma1(i, 1) * ma1(i, 3);
        end
        for i = 1:3
            H(1) = min(n * ma1(i, 1) * (1 - ttt(i)) + n * (1 - ma1(i, 1)), H(1));
        end
        for i = 1:3
            H(2) = min(n * ma1(i + 3, 1) * (1 - ttt(i)) + n * (1 - ma1(i + 3, 1)), H(2));
        end
        for i = 1:2
            H(3) = min(n * ma1(i + 6, 1) * (1 - ttt(i)) + n * (1 - ma1(i + 6, 1)), H(3));
        end
        for i = 1:3
            mon = mon + H(i) * ttt(i + 8) * ma2(i, 3) + H(i) * ma2(i, 2) + H(i) * ttt(i + 8) * ma2(i, 1) * ma2(i, 4) * ttt(i + 11);
        end
        for i = 1:3
            D = min(H(i) * ma2(i, 1) * (1 - ttt(i + 8)) + H(i) * (1 - ma2(i, 1)), D);
        end
        z = [ma2(1, 1) ma2(2, 1) ma2(3, 1) ma3(1)];
        for i = 1:4
            beta = beta + z(i);
            for j = i:4
                beta = beta - z(i) * z(j);
                for k = j:4
                    beta = beta + z(i) * z(j) * z(k);
                    for kk = k:4
                        beta = beta - z(i) * z(j) * z(k) * z(kk);
                    end
                end
            end
        end
        mon = mon + D * ma3(2) + D * ttt(14) * ma3(3) + D * (1 - ttt(14)) * 40 * beta + D * beta * ttt(15) * 40;
        nn = D * beta * ttt(15);
        n = nn * n / 100;
        inco = inco + D * ttt(14) * (1 - beta) + D * (1 - ttt(14)) * beta;
    end
end

%% 模拟题目中的步骤3、4
function anss = ObjFun(ttt, id, n)
    inco = 0;
    mon = 0;
    ma1 = [0.11538 2 1; 0.21154 8 1; 0.17308 12 2; 0.076923 2 1; 0.15385 8 1; 0.057692  12 2; 0.13462 8 1; 0.096154 12 2];
    ma2 = [0.13462 8 4 6; 0.19231 8 4 6; 0.11538 8 4 6];
    ma3 = [0.15385 8 6 10];
    for zzz = 1:2
        H = [1000 1000 1000];
        D = 1000;
        beta = 0;
        for i = 1:8
            mon = mon + ma1(i, 2) * ma1(i, 3) + ttt(i) * ma1(i, 1) * ma1(i, 3);
        end
        for i = 1:3
            H(1) = min(n * ma1(i, 1) * (1 - ttt(i)) + n * (1 - ma1(i, 1)), H(1));
        end
        for i = 1:3
            H(2) = min(n * ma1(i + 3, 1) * (1 - ttt(i)) + n * (1 - ma1(i + 3, 1)), H(2));
        end
        for i = 1:2
            H(3) = min(n * ma1(i + 6, 1) * (1 - ttt(i)) + n * (1 - ma1(i + 6, 1)), H(3));
        end
        for i = 1:3
            mon = mon + H(i) * ttt(i + 8) * ma2(i, 3) + H(i) * ma2(i, 2) + H(i) * ttt(i + 8) * ma2(i, 1) * ma2(i, 4) * ttt(i + 11);
        end
        for i = 1:3
            D = min(H(i) * ma2(i, 1) * (1 - ttt(i + 8)) + H(i) * (1 - ma2(i, 1)), D);
        end
        z = [ma2(1, 1) ma2(2, 1) ma2(3, 1) ma3(1)];
        for i = 1:4
            beta = beta + z(i);
            for j = i:4
                beta = beta - z(i) * z(j);
                for k = j:4
                    beta = beta + z(i) * z(j) * z(k);
                    for kk = k:4
                        beta = beta - z(i) * z(j) * z(k) * z(kk);
                    end
                end
            end
        end
        mon = mon + D * ma3(2) + D * ttt(14) * ma3(3) + D * (1 - ttt(14)) * 40 * beta + D * beta * ttt(15) * 40;
        nn = D * beta * ttt(15);
        n = nn * n / 100;
        inco = inco + D * ttt(14) * (1 - beta) + D * (1 - ttt(14)) * beta;
    end
    anss = mon - inco * 200;
end

