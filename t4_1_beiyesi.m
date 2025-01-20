%% 代码说明
%通过贝叶斯更新函数，在问题二的背景下，该代码计算零配件1、配件2和成品的后验概率

%% 数据初始化
clc
clear
%Part1为零部件1，Part2为零部件2，Product为成品
% defect_rate为次品率        purchase_price为购买单价     
% inspection_cost为检测成本  assembly_cost为装配成本
ifs = struct(...
    'Scenario1', struct('Part1', struct('defect_rate', 0.1, 'purchase_price', 4, 'inspection_cost', 2), ...
                        'Part2', struct('defect_rate', 0.1, 'purchase_price', 18, 'inspection_cost', 3), ...
                        'Product', struct('defect_rate', 0.1, 'assembly_cost', 6, 'inspection_cost', 3)), ...
    'Scenario2', struct('Part1', struct('defect_rate', 0.2, 'purchase_price', 4, 'inspection_cost', 2), ...
                        'Part2', struct('defect_rate', 0.2, 'purchase_price', 18, 'inspection_cost', 3), ...
                        'Product', struct('defect_rate', 0.2, 'assembly_cost', 6, 'inspection_cost', 3)), ...
    'Scenario3', struct('Part1', struct('defect_rate', 0.1, 'purchase_price', 4, 'inspection_cost', 2), ...
                        'Part2', struct('defect_rate', 0.1, 'purchase_price', 18, 'inspection_cost', 3), ...
                        'Product', struct('defect_rate', 0.1, 'assembly_cost', 6, 'inspection_cost', 3)), ...
    'Scenario4', struct('Part1', struct('defect_rate', 0.2, 'purchase_price', 4, 'inspection_cost', 1), ...
                        'Part2', struct('defect_rate', 0.2, 'purchase_price', 18, 'inspection_cost', 1), ...
                        'Product', struct('defect_rate', 0.2, 'assembly_cost', 6, 'inspection_cost', 2)), ...
    'Scenario5', struct('Part1', struct('defect_rate', 0.1, 'purchase_price', 4, 'inspection_cost', 8), ...
                        'Part2', struct('defect_rate', 0.2, 'purchase_price', 18, 'inspection_cost', 1), ...
                        'Product', struct('defect_rate', 0.1, 'assembly_cost', 6, 'inspection_cost', 2)), ...
    'Scenario6', struct('Part1', struct('defect_rate', 0.05, 'purchase_price', 4, 'inspection_cost', 2), ...
                        'Part2', struct('defect_rate', 0.05, 'purchase_price', 18, 'inspection_cost', 3), ...
                        'Product', struct('defect_rate', 0.05, 'assembly_cost', 6, 'inspection_cost', 3)) ...
);

% 定义采样数据
sample_data = struct(...
    'Part1', struct('k', 5, 'n', 50), ...
    'Part2', struct('k', 10, 'n', 50), ...
    'Product', struct('k', 8, 'n', 50) ...
);

% 初始化先验参数
alpha_pro = 1;
beta_pro = 1;

% 初始化结果数组
update_results = cell(length(fieldnames(ifs)), 1);

%% 调用函数，计算具体的值
% 遍历每个场景
if_names = fieldnames(ifs);
for i = 1:length(if_names)
    scenario_name = if_names{i};
    scenario_data = ifs.(scenario_name);
    
    result = struct('Scenario', scenario_name);
    
    % 更新Part1的次品率
    k1 = sample_data.Part1.k;
    n1 = sample_data.Part1.n;
    [alpha_post1, beta_post1] = beiyesi_update(k1, n1, alpha_pro, beta_pro);
    updated_theta1 = expected_defective_rate(alpha_post1, beta_post1);
    result.Part1_updated_defect_rate = updated_theta1;
    
    % 更新Part2的次品率
    k2 = sample_data.Part2.k;
    n2 = sample_data.Part2.n;
    [alpha_post2, beta_post2] = beiyesi_update(k2, n2, alpha_pro, beta_pro);
    updated_theta2 = expected_defective_rate(alpha_post2, beta_post2);
    result.Part2_updated_defect_rate = updated_theta2;
    
    % 更新Product的次品率
    k_prod = sample_data.Product.k;
    n_prod = sample_data.Product.n;
    [alpha_post_prod, beta_post_prod] = beiyesi_update(k_prod, n_prod, alpha_pro, beta_pro);
    update_theta_prod = expected_defective_rate(alpha_post_prod, beta_post_prod);
    result.Product_updated_defect_rate = update_theta_prod;
    
    % 将结果存储到数组中
    update_results{i} = result;
end

% 将结果转换为表格并打印
results_table = struct2table(cell2mat(update_results));
disp(results_table);

%% 函数定义
% 定义贝叶斯更新函数
function [alpha_post, beta_post] = beiyesi_update(k, n, alpha_prior, beta_pro)
    alpha_post = alpha_prior + k;
    beta_post = beta_pro + (n - k);
end

% 计算后验概率
function theta = expected_defective_rate(alpha_after, beta_after)
    theta = alpha_after / (alpha_after + beta_after);
end

