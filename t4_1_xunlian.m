%% 代码说明
%用训练好的鲸鱼算法进行求解第四问_问题二
%通过修改第17行的id，可以得到六种情况的决策方案
%id的值与题目中的1、2、3、4、5、6相对应

%% 主程序
clc
clear
jingyushu = 10;  % 鲸鱼数量
MAXGEN = 50;    % 最大迭代次数
weidu = 4;       % 决策变量的维度
ub = 1 * ones(1, weidu);  % 决策变量的上界
lb = 0 * ones(1, weidu);  % 决策变量的下界
L_p = zeros(1, weidu);    % 最优解的位置
%修改id，即可得到六种情况下的决策方案
id = 1;                    % 情况编号
L_s = inf;                 % 最优解的适应度值
PS = rand(jingyushu, weidu) .* repmat(ub - lb, jingyushu, 1) + repmat(lb, jingyushu, 1);  % 初始化鲸鱼位置
trace = zeros(1, MAXGEN);  % 记录每一代的最优适应度值

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
        fitness = ObjFun(PS(i, :), id);
        
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

%% 结果输出
name = ["零配件1是否检测", "零配件2是否检测", "成品是否检测", "不合格成品是否拆解"];
[ans1, ans2] = ObjFun1(L_p, id);
plot(trace, 'LineWidth', 2);
xlabel('迭代次数');
ylabel('适应度值');
title('适应度曲线');
fprintf("情况：%d\n", id);
answer = [name; string(L_p)];
for i = 1:4
    disp(name(i) + ':' + num2str(L_p(i)));
end
disp('成本:');
disp(ans1);
disp('收入:');
disp(ans2 * 56);

%% 目标函数
function anss = ObjFun(ttt, id)
    n1 = 100; n2 = 100;
    maa = [0.115385 4 2 0.211538 18 3 0.173077 6 3 56 6 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 6 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 30 5;
           0.115385 4 1 0.211538 18 1 0.173077 6 2 56 30 5;
           0.115385 4 8 0.211538 18 1 0.173077 6 2 56 10 5;
           0.115385 4 2 0.211538 18 3 0.173077 6 3 56 10 40];
    a = maa(id, 1); b = maa(id, 2); c = maa(id, 3);
    a1 = maa(id, 4); b1 = maa(id, 5); c1 = maa(id, 6);
    a2 = maa(id, 7); b2 = maa(id, 8); c2 = maa(id, 9); d2 = maa(id, 10);
    a3 = maa(id, 11); b3 = maa(id, 12);
    ce1 = ttt(1); ce2 = ttt(2); ce3 = ttt(3); ce4 = ttt(4);
    D = min(n1 * ce1 * (1 - a) + n1 * (1 - ce1), n2 * ce2 * (1 - a1) + n2 * (1 - ce2));
    beta = a + a1 + a2 - a * a1 - a * a2 - a1 * a2 + a * a1 * a2;
    inco = D * ce3 * (1 - beta) + D * (1 - ce3) * beta;
    mon = n1 * b + n2 * b1 + n1 * ce1 * c + n2 * ce2 * c1 + D * b2 + D * ce3 * c2 + D * (1 - ce3) * a3 * beta + D * beta * ce4 * b3;
    nn = D * beta * ce4;
    DD = min(nn * ce1 * (1 - a) + nn * (1 - ce1), nn * ce2 * (1 - a1) + nn * (1 - ce2));
    mon = mon + nn * (ce1 * c + ce2 * c) + DD * b2 + DD * ce3 * c2;
    inco = inco + DD * ce3 * (1 - beta) + DD * (1 - ce3) * beta;
    anss = mon - inco * 56;
end

%% 目标函数1
function [mon, inco] = ObjFun1(ttt, id)
    n1 = 100; n2 = 100;
    maa = [0.15 4 2 0.15 18 3 0.15 6 3 56 6 5;
           0.15 4 2 0.15 18 3 0.14 6 3 56 6 5;
           0.15 4 2 0.15 18 3 0.15 6 3 56 30 5;
           0.15 4 1 0.15 18 1 0.15 6 2 56 30 5;
           0.15 4 8 0.15 18 1 0.15 6 2 56 10 5;
           0.15 4 2 0.15 18 3 0.14 6 3 56 10 40];
    a = maa(id, 1); b = maa(id, 2); c = maa(id, 3);
    a1 = maa(id, 4); b1 = maa(id, 5); c1 = maa(id, 6);
    a2 = maa(id, 7); b2 = maa(id, 8); c2 = maa(id, 9); d2 = maa(id, 10);
    a3 = maa(id, 11); b3 = maa(id, 12);
    ce1 = ttt(1); ce2 = ttt(2); ce3 = ttt(3); ce4 = ttt(4);
    D = min(n1 * ce1 * (1 - a) + n1 * (1 - ce1), n2 * ce2 * (1 - a1) + n2 * (1 - ce2));
    beta = a + a1 + a2 - a * a1 - a * a2 - a1 * a2 + a * a1 * a2;
    inco = D * ce3 * (1 - beta) + D * (1 - ce3) * beta;
    mon = n1 * b + n2 * b1 + n1 * ce1 * c + n2 * ce2 * c1 + D * b2 + D * ce3 * c2 + D * (1 - ce3) * a3 * beta + D * beta * ce4 * b3;
    nn = D * beta * ce4;
    DD = min(nn * ce1 * (1 - a) + nn * (1 - ce1), nn * ce2 * (1 - a1) + nn * (1 - ce2));
    mon = mon + nn * (ce1 * c + ce2 * c) + DD * b2 + DD * ce3 * c2;
    inco = inco + DD * ce3 * (1 - beta) + DD * (1 - ce3) * beta;
end