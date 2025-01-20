%% 代码说明
% 求解第四问-问题二情况下的代码
% 训练鲸鱼算法
% 鲸鱼数量：10
% 最大迭代数为：50
% 决策变量的纬度为：4

%% 主程序
clc
clear
jingyushu = 10;  % 鲸鱼数量
MAXGEN = 50;    % 最大迭代次数
weidu = 4;      % 决策变量的维度
ub = 1 * ones(1, weidu);  % 决策变量的上界
lb = 0 * ones(1, weidu);  % 决策变量的下界
L_p = zeros(1, weidu);    % 最优解的位置
id = 6;                    % 情况编号
L_s = inf;                 % 最优解的适应度值
PS = rand(jingyushu, weidu) .* repmat(ub - lb, jingyushu, 1) + repmat(lb, jingyushu, 1);  % 初始化鲸鱼位置
trace = zeros(1, MAXGEN);  % 记录每一代的最优适应度值

% 定义 n1 和 n2 的范围
n1_values = 100:100:1000;
n2_values = 100:100:1000;

% 初始化结果表格
results = cell(length(n1_values) * length(n2_values), 8);
row_index = 1;

for n1 = n1_values
    for n2 = n1
        % 重置最优解
        L_p = zeros(1, weidu);
        L_s = inf;
        
        for kk = 1:MAXGEN
            % 更新参数
            a = 2 - kk * (2 / MAXGEN);  % 线性递减的参数a
            a2 = -1 + kk * (1 / MAXGEN);  % 线性递减的参数a2
            
            % 计算适应度值并更新最优解
            for i = 1:jingyushu
                % 边界处理：越界赋值为边界值
                PS(i, :) = min(max(PS(i, :), lb), ub);
                
                % 计算适应度值
                fitness = ObjFun(PS(i, :), id, n1, n2);
                
                % 更新最优解
                if fitness < L_s
                    L_s = fitness;
                    L_p = PS(i, :);
                end
            end
            
            % 更新鲸鱼位置
            r1 = rand(jingyushu, 1);
            r2 = rand(jingyushu, 1);
            A = 2 * a * r1 - a;  % 参数A
            C = 2 * r2;          % 参数C
            b = 1;               % 螺旋参数
            l = (a2 - 1) * rand(jingyushu, 1) + 1;  % 螺旋参数
            p = rand(jingyushu, 1);  % 随机选择更新方式
            
            for i = 1:jingyushu
                if p(i) < 0.5  % 包围捕食
                    if abs(A(i)) < 1
                        D = abs(C(i) * L_p - PS(i, :));
                        PS(i, :) = L_p - A(i) * D;
                    else
                        rand_leader_index = randi(jingyushu);
                        X_rand = PS(rand_leader_index, :);
                        D_X_rand = abs(C(i) * X_rand - PS(i, :));
                        PS(i, :) = X_rand - A(i) * D_X_rand;
                    end
                else  % 螺旋更新
                    distance_Leader = abs(L_p - PS(i, :));
                    PS(i, :) = distance_Leader .* exp(b * l(i)) .* cos(l(i) * 2 * pi) + L_p;
                end
            end
            
            % 记录当前代的最优适应度值
            trace(kk) = L_s;
        end
              
        % 结果输出
        [ans1, ans2] = ObjFun1(L_p, id, n1, n2);
        
        % 保存结果到表格
        results{row_index, 1} = n1;
        results{row_index, 2} = n2;
        results{row_index, 3} = L_p(1);
        results{row_index, 4} = L_p(2);
        results{row_index, 5} = L_p(3);
        results{row_index, 6} = L_p(4);
        results{row_index, 7} = ans1;
        results{row_index, 8} = ans2 * 56;
        
        row_index = row_index + 1;
    end
end

% 显示结果表格
disp("第"+id+"种情况下的决策方案");
results_table = cell2table(results, 'VariableNames', {'n1', 'n2', '零配件1是否检测', '零配件2是否检测', '成品是否检测', '不合格成品是否拆解', '成本', '收入'});
disp(results_table);

%% 模拟题目中的步骤1、2
function [money1, inco] = ObjFun1(ttt, id, n1, n2)
    maa = [0.115385 4 2 0.211538 18 3 0.173077 6 3 56 6 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 6 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 30 5;
           0.115385 4 1 0.211538 18 1 0.173077 6 2 56 30 5;
           0.115385 4 8 0.211538 18 1 0.173077 6 2 56 10 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 10 40];
    a = maa(id, 1); %零部件1的次品率
    b = maa(id, 2); %零部件1的购买单价
    c = maa(id, 3); %零部件1的检测成本
    a1 = maa(id, 4); %零部件2的次品率
    b1 = maa(id, 5); %零部件2的购买单价
    c1 = maa(id, 6); %零部件2的检测成本
    a2 = maa(id, 7); %成品的次品率
    b2 = maa(id, 8); %成品的装配成本
    c2 = maa(id, 9); %成品的检测成本
    d2 = maa(id, 10);%成品的市场售价
    a3 = maa(id, 11);%不合格成品的调换损失
    b3 = maa(id, 12);%不合格成品的拆解费用
    ce1 = ttt(1); 
    ce2 = ttt(2); 
    ce3 = ttt(3); 
    ce4 = ttt(4);
    theta1 = min(n1 * ce1 * (1 - a) + n1 * (1 - ce1), n2 * ce2 * (1 - a1) + n2 * (1 - ce2));
    beta = a + a1 + a2 - a * a1 - a * a2 - a1 * a2 + a * a1 * a2;
    inco = theta1 * ce3 * (1 - beta) + theta1 * (1 - ce3) * beta;
    money1 = n1 * b + n2 * b1 + n1 * ce1 * c + n2 * ce2 * c1 + theta1 * b2 + theta1 * ce3 * c2 + theta1 * (1 - ce3) * a3 * beta + theta1 * beta * ce4 * b3;
    nn = theta1 * beta * ce4;
    theta2 = min(nn * ce1 * (1 - a) + nn * (1 - ce1), nn * ce2 * (1 - a1) + nn * (1 - ce2));
    money1 = money1 + nn * (ce1 * c + ce2 * c) + theta2 * b2 + theta2 * ce3 * c2;
    inco = inco + theta2 * ce3 * (1 - beta) + theta2 * (1 - ce3) * beta;
end

%% 模拟题目中的步骤3、4
function revenue = ObjFun(ttt, id, n1, n2)
    maa = [0.115385 4 2 0.211538 18 3 0.173077 6 3 56 6 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 6 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 30 5;
           0.115385 4 1 0.211538 18 1 0.173077 6 2 56 30 5;
           0.115385 4 8 0.211538 18 1 0.173077 6 2 56 10 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 10 40];
    a = maa(id, 1); %零部件1的次品率
    b = maa(id, 2); %零部件1的购买单价
    c = maa(id, 3); %零部件1的检测成本
    a1 = maa(id, 4); %零部件2的次品率
    b1 = maa(id, 5); %零部件2的购买单价
    c1 = maa(id, 6); %零部件2的检测成本
    a2 = maa(id, 7); %成品的次品率
    b2 = maa(id, 8); %成品的装配成本
    c2 = maa(id, 9); %成品的检测成本
    d2 = maa(id, 10);%成品的市场售价
    a3 = maa(id, 11);%不合格成品的调换损失
    b3 = maa(id, 12);%不合格成品的拆解费用
    ce1 = ttt(1); 
    ce2 = ttt(2); 
    ce3 = ttt(3); 
    ce4 = ttt(4);
    theta1 = min(n1 * ce1 * (1 - a) + n1 * (1 - ce1), n2 * ce2 * (1 - a1) + n2 * (1 - ce2));
    beta = a + a1 + a2 - a * a1 - a * a2 - a1 * a2 + a * a1 * a2;
    inco = theta1 * ce3 * (1 - beta) + theta1 * (1 - ce3) * beta;
    money2 = n1 * b + n2 * b1 + n1 * ce1 * c + n2 * ce2 * c1 + theta1 * b2 + theta1 * ce3 * c2 + theta1 * (1 - ce3) * a3 * beta + theta1 * beta * ce4 * b3;
    nn = theta1 * beta * ce4;
    theta2 = min(nn * ce1 * (1 - a) + nn * (1 - ce1), nn * ce2 * (1 - a1) + nn * (1 - ce2));
    money2 = money2 + nn * (ce1 * c + ce2 * c) + theta2 * b2 + theta2 * ce3 * c2;
    inco = inco + theta2 * ce3 * (1 - beta) + theta2 * (1 - ce3) * beta;
    revenue = money2 - inco * 56;
end
