%% 第三问的检验代码
%% 零部件参数
clc;
clear;
components = struct(...
    'part1', struct('defect_rate', 0.1, 'purchase_price', 2, 'inspection_cost', 1), ...
    'part2', struct('defect_rate', 0.1, 'purchase_price', 8, 'inspection_cost', 1), ...
    'part3', struct('defect_rate', 0.1, 'purchase_price', 12, 'inspection_cost', 2), ...
    'part4', struct('defect_rate', 0.1, 'purchase_price', 2, 'inspection_cost', 1), ...
    'part5', struct('defect_rate', 0.1, 'purchase_price', 8, 'inspection_cost', 1), ...
    'part6', struct('defect_rate', 0.1, 'purchase_price', 12, 'inspection_cost', 2), ...
    'part7', struct('defect_rate', 0.1, 'purchase_price', 8, 'inspection_cost', 1), ...
    'part8', struct('defect_rate', 0.1, 'purchase_price', 12, 'inspection_cost', 2) ...
);

% 半成品参数
semi_products = struct(...
    'semi_product1', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 4, 'dismantle_cost', 6), ...
    'semi_product2', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 4, 'dismantle_cost', 6), ...
    'semi_product3', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 4, 'dismantle_cost', 6) ...
);

% 成品参数
final_product = struct(...
    'final_product', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 6, 'dismantle_cost', 10, 'selling_price', 200, 'exchange_loss', 40) ...
);

% 定义零部件数量范围
component_quantities = 500;

%% 生成所有策略
% 生成所有可能的组合
% 使用二进制表示法生成所有可能的检测策略组合
component_combinations = dec2bin(0:2^8-1) == '1';
semi_combinations = dec2bin(0:2^3-1) == '1';
final_combinations = dec2bin(0:2^2-1) == '1';

% 次品率变化范围
defect_rate_range = 0.05:0.01:0.15;

% 初始化结果存储
total_costs = zeros(length(defect_rate_range), 1);

% 遍历次品率范围
for d = 1:length(defect_rate_range)
    % 更新 part1 的次品率
    components.part1.defect_rate = defect_rate_range(d);
    
    % 计算所有策略的成本和次品率
    total_cost = 0;
    for i = 1:size(component_combinations, 1)
        for j = 1:size(semi_combinations, 1)
            for k = 1:size(final_combinations, 1)
                detect_components = component_combinations(i, :);
                detect_semi = semi_combinations(j, :);
                detect_final = final_combinations(k, 1);
                dismantle = final_combinations(k, 2);

                % 调用函数计算当前策略的总成本和次品率
                [cost, ~, ~, ~, ~] = calculate_expected_cost(components, semi_products, final_product, detect_components, detect_semi, detect_final, dismantle, component_quantities);

                % 累加总成本
                total_cost = total_cost + cost;
            end
        end
    end
    
    % 存储总成本
    total_costs(d) = total_cost;
end
%% 计算灵敏度
% 计算灵敏度（导数）
sensitivity = diff(total_costs) ./ diff(defect_rate_range');

% 计算变化率
change_rate = sensitivity ./ total_costs(1:end-1);

% 可视化结果
figure;
subplot(2, 1, 1);
plot(defect_rate_range, total_costs, '-o', 'LineWidth', 2);
xlabel('样品1次品率');
ylabel('总成本');
grid on;

subplot(2, 1, 2);
plot(defect_rate_range(2:end), sensitivity, '-o', 'LineWidth', 2);
hold on;
plot(defect_rate_range(2:end), change_rate, '-s', 'LineWidth', 2);
xlabel('样品1次品率');
ylabel('灵敏度');
legend('灵敏度 (导数)', '变化率');
grid on;

%%
% 计算预期成本的函数
% 该函数计算给定策略的总成本和次品率
function [total_cost, total_defective_rate, component_costs, semi_product_costs, final_product_costs] = calculate_expected_cost(components, semi_products, final_product, detect_components, detect_semi, detect_final, dismantle, quantity)
    total_cost = 0;
    total_defective_rate = 1;
    component_costs = 0;
    semi_product_costs = 0;
    final_product_costs = 0;

    % 计算组件的成本和次品率
    component_names = fieldnames(components);
    for i = 1:length(component_names)
        comp_name = component_names{i};
        comp_data = components.(comp_name);
        purchase_cost = comp_data.purchase_price * quantity;
        inspection_cost = comp_data.inspection_cost * detect_components(i) * quantity;
        cost = purchase_cost + inspection_cost;
        defective_rate = comp_data.defect_rate * (1 - 0.5 * detect_components(i));
        component_costs = component_costs + cost;
        total_cost = total_cost + cost;
        total_defective_rate = total_defective_rate * (1 - defective_rate);
    end

    % 计算半成品的成本和次品率
    semi_product_names = fieldnames(semi_products);
    for i = 1:length(semi_product_names)
        semi_name = semi_product_names{i};
        semi_data = semi_products.(semi_name);
        assembly_cost = semi_data.assembly_cost * quantity;
        inspection_cost = semi_data.inspection_cost * detect_semi(i) * quantity;
        dismantle_cost = semi_data.dismantle_cost * detect_semi(i) * quantity;
        cost = assembly_cost + inspection_cost + dismantle_cost;
        defective_rate = semi_data.defect_rate * (1 - 0.5 * detect_semi(i));
        semi_product_costs = semi_product_costs + cost;
        total_cost = total_cost + cost;
        total_defective_rate = total_defective_rate * (1 - defective_rate);
    end

    % 计算成品的成本和次品率
    final_defective_rate = final_product.final_product.defect_rate * (0.5 * detect_final + 0.5 * ~detect_final);
    assembly_cost = final_product.final_product.assembly_cost * quantity;
    inspection_cost = final_product.final_product.inspection_cost * detect_final * quantity;
    dismantle_cost = final_product.final_product.dismantle_cost * dismantle * quantity;
    final_cost = assembly_cost + inspection_cost + dismantle_cost;

    final_product_costs = final_cost;
    total_cost = total_cost + final_cost;
    total_defective_rate = 1 - (total_defective_rate * (1 - final_defective_rate));

    % 计算由于次品率导致的损失
    exchange_loss = final_product.final_product.exchange_loss * total_defective_rate * quantity;
    total_cost = total_cost + exchange_loss;

    % 如果策略中包含拆解不合格成品，则增加拆解成本
    if dismantle
        dismantle_cost = final_product.final_product.dismantle_cost * quantity;
        final_product_costs = final_product_costs + dismantle_cost;
        total_cost = total_cost + dismantle_cost;
    end
end