
%% 主程序
clc
clear
jingyushu_values = [10, 20, 30];
MAXGEN_values = [50, 100, 150];
weidu_values = [2, 4, 6];

% 初始化结果表格
results = cell(length(jingyushu_values) * length(MAXGEN_values) * length(weidu_values), 10);
row_index = 1;

for jingyushu = jingyushu_values
    for MAXGEN = MAXGEN_values
        for weidu = weidu_values
            % 初始化参数
            ub = 1 * ones(1, weidu);  % 决策变量的上界
            lb = 0 * ones(1, weidu);  % 决策变量的下界
            L_p = zeros(1, weidu);    % 最优解的位置
            id = 2;                    % 情况编号
            L_s = inf;                 % 最优解的适应度值
            PS = rand(jingyushu, weidu) .* repmat(ub - lb, jingyushu, 1) + repmat(lb, jingyushu, 1);  % 初始化鲸鱼位置
            trace = zeros(1, MAXGEN);  % 记录每一代的最优适应度值

            % 定义 n1 和 n2 的范围
            n1_values = 100:100:1000;
            n2_values = 100:100:1000;

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
                    results{row_index, 1} = jingyushu;
                    results{row_index, 2} = MAXGEN;
                    results{row_index, 3} = weidu;
                    results{row_index, 4} = n1;
                    results{row_index, 5} = n2;
                    results{row_index, 6} = L_p(1);
                    results{row_index, 7} = L_p(2);
                    if length(L_p) >= 3
                        results{row_index, 8} = L_p(3);
                    else
                        results{row_index, 8} = NaN;
                    end
                    if length(L_p) >= 4
                        results{row_index, 9} = L_p(4);
                    else
                        results{row_index, 9} = NaN;
                    end
                    results{row_index, 10} = L_s;

                    row_index = row_index + 1;
                end
            end
        end
    end
end

% 显示结果表格
results_table = cell2table(results, 'VariableNames', {'jingyushu', 'MAXGEN', 'weidu', 'n1', 'n2', '零配件1是否检测', '零配件2是否检测', '成品是否检测', '不合格成品是否拆解', '最优适应度值'});
disp(results_table);

% 创建文件名
filename = 't4_test_results.xlsx';
% 将结果表写入Excel文件
writetable(results_table, filename);


%% 可视化处理
% 绘制不同参数设置下的最优适应度值
figure;
hold on;
for i = 1:length(jingyushu_values)
    for j = 1:length(MAXGEN_values)
        for k = 1:length(weidu_values)
            idx = (i-1)*length(MAXGEN_values)*length(weidu_values) + (j-1)*length(weidu_values) + k;
            plot(results{idx, 10}, 'DisplayName', sprintf('jingyushu=%d, MAXGEN=%d, weidu=%d', results{idx, 1}, results{idx, 2}, results{idx, 3}));
        end
    end
end

%% 目标函数
function anss = ObjFun(ttt, id, n1, n2)
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
    
    % 检查维度并设置默认值
    ce1 = ttt(1);
    ce2 = ttt(2);
    ce3 = 0;
    ce4 = 0;
    if length(ttt) >= 3
        ce3 = ttt(3);
    end
    if length(ttt) >= 4
        ce4 = ttt(4);
    end
    
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
function [mon, inco] = ObjFun1(ttt, id, n1, n2)
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
    
    % 检查维度并设置默认值
    ce1 = ttt(1);
    ce2 = ttt(2);
    ce3 = 0;
    ce4 = 0;
    if length(ttt) >= 3
        ce3 = ttt(3);
    end
    if length(ttt) >= 4
        ce4 = ttt(4);
    end
    
    D = min(n1 * ce1 * (1 - a) + n1 * (1 - ce1), n2 * ce2 * (1 - a1) + n2 * (1 - ce2));
    beta = a + a1 + a2 - a * a1 - a * a2 - a1 * a2 + a * a1 * a2;
    inco = D * ce3 * (1 - beta) + D * (1 - ce3) * beta;
    mon = n1 * b + n2 * b1 + n1 * ce1 * c + n2 * ce2 * c1 + D * b2 + D * ce3 * c2 + D * (1 - ce3) * a3 * beta + D * beta * ce4 * b3;
    nn = D * beta * ce4;
    DD = min(nn * ce1 * (1 - a) + nn * (1 - ce1), nn * ce2 * (1 - a1) + nn * (1 - ce2));
    mon = mon + nn * (ce1 * c + ce2 * c) + DD * b2 + DD * ce3 * c2;
    inco = inco + DD * ce3 * (1 - beta) + DD * (1 - ce3) * beta;
end