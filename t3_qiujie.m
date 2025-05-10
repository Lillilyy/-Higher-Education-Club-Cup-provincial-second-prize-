%% 问题三的求解代码:
%由于数据量较大，该代码大概会运行12分钟左右（电脑环境：12核，线程数16）

%% 使用结构体定义各个组件、半成品和成品的参数，包括次品率、采购价格、检测成本等

% 零部件参数
% defect_rate为次品率，purchase_price为购买单价，inspection_cost为检测成本
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
% defect_rate为次品率，assembly_cost为装配成本
% inspection_cost为检测成本，dismantle_cost为拆解成本
semi_products = struct(...
    'semi_product1', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 4, 'dismantle_cost', 6), ...
    'semi_product2', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 4, 'dismantle_cost', 6), ...
    'semi_product3', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 4, 'dismantle_cost', 6) ...
);

% 成品参数
% defect_rate为次品率，assembly_cost为装配成本，inspection_cost为检测成本
% dismantle_cost为拆解费用，selling_price为市场售价，exchange_loss为调换损失
final_product = struct(...
    'final_product', struct('defect_rate', 0.1, 'assembly_cost', 8, 'inspection_cost', 6, 'dismantle_cost', 10, 'selling_price', 200, 'exchange_loss', 40) ...
);

%%
% 生成所有可能的组合
% 使用二进制表示法生成所有可能的检测策略组合
component_combinations = dec2bin(0:2^8-1) == '1';
pro_combinations = dec2bin(0:2^3-1) == '1';
final_combinations = dec2bin(0:2^2-1) == '1';

% 初始化结果存储
% 初始化一个空的单元格数组来存储每个策略的结果
results = cell(0, 10);
strategy_number = 1;

% 定义零部件数量范围
component_quantities = 100:100:1000;

%%
% 计算所有策略的成本和次品率
% 遍历所有可能的组合，计算每个策略的总成本和次品率
for q = 1:length(component_quantities)
    quantity = component_quantities(q);
    for i = 1:size(component_combinations, 1)
        for j = 1:size(pro_combinations, 1)
            for k = 1:size(final_combinations, 1)
                detect_components = component_combinations(i, :);
                detect_semi = pro_combinations(j, :);
                detect_final = final_combinations(k, 1);
                dismantle = final_combinations(k, 2);

                % 调用函数计算当前策略的总成本和次品率
                [cost, defective_rate, component_costs, semi_product_costs, final_product_costs] = calculate_expected_cost(components, semi_products, final_product, detect_components, detect_semi, detect_final, dismantle, quantity);

                % 生成当前策略的描述
                strategy_description = generate_strategy_description(detect_components, detect_semi, detect_final, dismantle);
                
                % 将策略编号、描述、总成本、次品率、零部件数量、各阶段费用存储到结果数组中
                results = [results; {strategy_number, strategy_description, cost, defective_rate, quantity, component_costs, semi_product_costs, final_product_costs}];
                strategy_number = strategy_number + 1;
            end
        end
    end
end

% 将结果保存到Excel文件
% 将结果数组转换为表格，并保存到Excel文件中
%这里的费用指的是检验+拆解的总费用（如果没有拆解，就只是检验的费用）
results_table = cell2table(results, 'VariableNames', {'策略编号', '策略描述', '总成本', '成品次品率', '零部件数量', '零部件费用', '半成品费用', '成品费用'});
writetable(results_table, 't3_results.xlsx', 'WriteVariableNames', true);

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

%%
% 生成策略描述的函数
% 该函数生成当前策略的描述字符串
function description = generate_strategy_description(detect_components, detect_semi, detect_final, dismantle)
    description = '';
    component_names = {'零配件1', '零配件2', '零配件3', '零配件4', '零配件5', '零配件6', '零配件7', '零配件8'};
    for i = 1:length(detect_components)
        if detect_components(i)
            description = [description, sprintf('检测%s，', component_names{i})];
        else
            description = [description, sprintf('不检测%s，', component_names{i})];
        end
    end
    semi_product_names = {'半成品1', '半成品2', '半成品3'};
    for i = 1:length(detect_semi)
        if detect_semi(i)
            description = [description, sprintf('检测%s，', semi_product_names{i})];
        else
            description = [description, sprintf('不检测%s，', semi_product_names{i})];
        end
    end
    if detect_final
        description = [description, '检测成品，'];
    else
        description = [description, '不检测成品，'];
    end
    if dismantle
        description = [description, '拆解不合格成品'];
    else
        description = [description, '不拆解不合格成品'];
    end
end