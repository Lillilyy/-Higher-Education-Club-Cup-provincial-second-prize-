%% 第二问蒙特卡洛检验代码
clc; % 清除命令窗口
clear; % 清除工作区变量

%% 定义情况的参数
cases = [
    %defect_rate1为零配件1的次品率，defect_rate2为零配件2的次品率
    %defect_rate_final为成品次品率
    
    %inspection_cost1为零配件1的检测成本，inspection_cost2为零配件2的检测成本
    %inspection_cost_final为成品的检测成本
    
    %assembly_cost为成品的装配成品，market_price为成品的市场售价
    %replacement_loss为不合格成品的调换损失，dismantle_cost为不合格成品的拆解成品
    
    struct('defect_rate1', 0.1, 'defect_rate2', 0.1, 'defect_rate_final', 0.1, 'inspection_cost1', 2, 'inspection_cost2', 3, ...
           'inspection_cost_final', 3, 'assembly_cost', 6, 'market_price', 56, 'replacement_loss', 6, 'dismantle_cost', 5);
    struct('defect_rate1', 0.2, 'defect_rate2', 0.2, 'defect_rate_final', 0.2, 'inspection_cost1', 2, 'inspection_cost2', 3, ...
           'inspection_cost_final', 3, 'assembly_cost', 6, 'market_price', 56, 'replacement_loss', 6, 'dismantle_cost', 5);
    struct('defect_rate1', 0.1, 'defect_rate2', 0.1, 'defect_rate_final', 0.1, 'inspection_cost1', 2, 'inspection_cost2', 3, ...
           'inspection_cost_final', 3, 'assembly_cost', 6, 'market_price', 56, 'replacement_loss', 30, 'dismantle_cost', 5);
    struct('defect_rate1', 0.2, 'defect_rate2', 0.2, 'defect_rate_final', 0.2, 'inspection_cost1', 1, 'inspection_cost2', 1, ...
           'inspection_cost_final', 2, 'assembly_cost', 6, 'market_price', 56, 'replacement_loss', 30, 'dismantle_cost', 5);
    struct('defect_rate1', 0.1, 'defect_rate2', 0.2, 'defect_rate_final', 0.1, 'inspection_cost1', 8, 'inspection_cost2', 1, ...
           'inspection_cost_final', 2, 'assembly_cost', 6, 'market_price', 56, 'replacement_loss', 10, 'dismantle_cost', 5);
    struct('defect_rate1', 0.05, 'defect_rate2', 0.05, 'defect_rate_final', 0.05, 'inspection_cost1', 2, 'inspection_cost2', 3, ...
           'inspection_cost_final', 3, 'assembly_cost', 6, 'market_price', 56, 'replacement_loss', 10, 'dismantle_cost', 40);
];

%% 生成所有策略
strategies = []; % 初始化策略数组
for detect_parts1 = [true, false] % 遍历是否检测零配件1
    for detect_parts2 = [true, false] % 遍历是否检测零配件2
        for detect_final = [true, false] % 遍历是否检测成品
            for dismantle = [true, false] % 遍历是否拆解不合格成品
                % 将当前策略组合添加到策略数组中
                strategies = [strategies; struct('detect_parts1', detect_parts1, 'detect_parts2', detect_parts2, ...
                                                 'detect_final', detect_final, 'dismantle', dismantle)];
            end
        end
    end
end

% 生成策略解释
strategy_explanations = cell(size(strategies)); % 初始化策略解释数组
for i = 1:length(strategies) % 遍历所有策略
    strategy = strategies(i); % 获取当前策略
    % 生成当前策略的解释字符串
    strategy_explanations{i} = sprintf('方案 %d: 检测零配件1： %s，检测零配件2： %s，检测成品： %s，拆解不合格成品： %s', ...
        i, string(strategy.detect_parts1), string(strategy.detect_parts2), string(strategy.detect_final), string(strategy.dismantle));
end

% 定义数量范围
n_range = 100:100:1000;

% 初始化结果表格
results = cell(length(cases) * length(n_range) * length(strategies), 6);
row_index = 1;

%% 计算每个情况下的总成本和次品率
for i = 1:length(cases) % 遍历所有情况
    fprintf('\n情况 %d:\n', i); % 打印当前情况编号
    for n = n_range % 遍历数量范围
        fprintf('数量: %d\n', n); % 打印当前数量
        for j = 1:length(strategies) % 遍历所有策略
            % 计算当前情况和策略下的总成本和次品率
            [total_cost, defective_rate] = calc_total_cost(cases(i), strategies(j).detect_parts1, strategies(j).detect_parts2, ...
                                                           strategies(j).detect_final, strategies(j).dismantle, n);
            % 存储结果到表格
            results{row_index, 1} = i; % 情况编号
            results{row_index, 2} = n; % 数量
            results{row_index, 3} = strategy_explanations{j}; % 策略解释
            results{row_index, 4} = total_cost; % 总成本
            results{row_index, 5} = defective_rate; % 次品率
            results{row_index, 6} = strategy_explanations{j}; % 策略解释
            row_index = row_index + 1;
            fprintf('%s: 总成本 = %.2f, 次品率 = %.2f\n', strategy_explanations{j}, total_cost, defective_rate); % 打印当前策略的总成本和次品率
        end
    end
end


%% 蒙特卡洛模拟
num_simulations = 1000; % 模拟次数
defective_rates_with_uncertainty = zeros(num_simulations, 1);
defective_rates_without_uncertainty = zeros(num_simulations, 1);

for i = 1:num_simulations
    % 随机选择一个情况和策略
    case_index = randi(length(cases));
    strategy_index = randi(length(strategies));
    n = n_range(randi(length(n_range)));
    
    % 计算没有随机性的次品率
    [~, defective_rate_without_uncertainty] = calc_total_cost(cases(case_index), strategies(strategy_index).detect_parts1, ...
                                                              strategies(strategy_index).detect_parts2, strategies(strategy_index).detect_final, ...
                                                              strategies(strategy_index).dismantle, n);
    defective_rates_without_uncertainty(i) = defective_rate_without_uncertainty;
    
    % 计算有随机性的次品率
    [~, defective_rate_with_uncertainty] = calc_total_cost_with_uncertainty(cases(case_index), strategies(strategy_index).detect_parts1, ...
                                                                           strategies(strategy_index).detect_parts2, strategies(strategy_index).detect_final, ...
                                                                           strategies(strategy_index).dismantle, n);
    defective_rates_with_uncertainty(i) = defective_rate_with_uncertainty;
end

%% 可视化结果
figure;
subplot(2,1,1);
histogram(defective_rates_without_uncertainty, 'Normalization', 'pdf');
title('未添加随机性的次品率分布');
xlabel('次品率');
ylabel('概率密度');

subplot(2,1,2);
histogram(defective_rates_with_uncertainty, 'Normalization', 'pdf');
title('添加随机性的次品率分布');
xlabel('次品率');
ylabel('概率密度');

%% 计算总成本的函数（没有随机性）
function [total_cost, defective_rate] = calc_total_cost(current_case, detect_parts1, detect_parts2, detect_final, dismantle, n)
    n_1 = n; % 零配件1的数量
    n_2 = n; % 零配件2的数量
    n_final_products = n; % 成品数量
    money = n_1 * 4 + n_2 * 18; % 零配件1、2的购入成本
    
    cost_1 = n_1 * current_case.inspection_cost1 * detect_parts1; % 零配件1的检测成本
    cost_2 = n_2 * current_case.inspection_cost2 * detect_parts2; % 零配件2的检测成本

    loss_1 = (n_1 * current_case.defect_rate1) * current_case.assembly_cost * ~detect_parts1; % 零配件1的损失成本
    loss_2 = (n_2 * current_case.defect_rate2) * current_case.assembly_cost * ~detect_parts2; % 零配件2的损失成本

    cost_final = n_final_products * current_case.inspection_cost_final * detect_final; % 成品的检测成本
    loss_final = (n_final_products * current_case.defect_rate_final) * current_case.replacement_loss * ~detect_final; % 成品的损失成本

    cost_3 = n_final_products * current_case.dismantle_cost * dismantle; % 拆解不合格成品的成本
    dismantle_revenue = (n_final_products * current_case.defect_rate_final) * current_case.market_price * dismantle; % 拆解不合格成品的收入

    total_cost = money + cost_1 + cost_2 + loss_1 + loss_2 + cost_final + loss_final + cost_3; % 总成本
    defective_rate = current_case.defect_rate_final * (1 - detect_final * 0.5); % 次品率
end

%% 计算总成本的函数（有随机性）
function [total_cost, defective_rate] = calc_total_cost_with_uncertainty(current_case, detect_parts1, detect_parts2, detect_final, dismantle, n)
    n_1 = n; % 零配件1的数量
    n_2 = n; % 零配件2的数量
    n_final_products = n; % 成品数量
    money = n_1 * 4 + n_2 * 18; % 零配件1、2的购入成本
    
    % 引入随机性，假设次品率服从正态分布
    defect_rate1_random = max(0, min(1, normrnd(current_case.defect_rate1, 0.05)));
    defect_rate2_random = max(0, min(1, normrnd(current_case.defect_rate2, 0.05)));
    defect_rate_final_random = max(0, min(1, normrnd(current_case.defect_rate_final, 0.05)));
    
    cost_1 = n_1 * current_case.inspection_cost1 * detect_parts1; % 零配件1的检测成本
    cost_2 = n_2 * current_case.inspection_cost2 * detect_parts2; % 零配件2的检测成本

    loss_1 = (n_1 * defect_rate1_random) * current_case.assembly_cost * ~detect_parts1; % 零配件1的损失成本
    loss_2 = (n_2 * defect_rate2_random) * current_case.assembly_cost * ~detect_parts2; % 零配件2的损失成本

    cost_final = n_final_products * current_case.inspection_cost_final * detect_final; % 成品的检测成本
    loss_final = (n_final_products * defect_rate_final_random) * current_case.replacement_loss * ~detect_final; % 成品的损失成本

    cost_3 = n_final_products * current_case.dismantle_cost * dismantle; % 拆解不合格成品的成本
    dismantle_revenue = (n_final_products * defect_rate_final_random) * current_case.market_price * dismantle; % 拆解不合格成品的收入

    total_cost = money + cost_1 + cost_2 + loss_1 + loss_2 + cost_final + loss_final + cost_3; % 总成本
    defective_rate = defect_rate_final_random * (1 - detect_final * 0.5); % 次品率
end