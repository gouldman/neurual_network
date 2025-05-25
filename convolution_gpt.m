% 参数设置
input_size = 28;
kernel_size = 5;
num_channels = 3;
padding = floor(kernel_size / 2);  % zero padding = 2

% 随机生成输入数据和卷积核权重（范围 0~3 的整数）
input_data = randi([0, 3], input_size, input_size, num_channels);
kernel_weights = randi([0, 3], kernel_size, kernel_size, num_channels);

% 打印原始输入数据
disp('--- 原始输入数据（每个通道） ---');
for c = 1:num_channels
    fprintf('Channel %d:\n', c);
    disp(input_data(:, :, c));
end

% 打印卷积核权重
disp('--- 卷积核权重（每个通道） ---');
for c = 1:num_channels
    fprintf('Channel %d:\n', c);
    disp(kernel_weights(:, :, c));
end

% 手动实现 zero padding（输出尺寸为 32x32x3）
padded_size = input_size + 2 * padding;
padded_input = zeros(padded_size, padded_size, num_channels);
padded_input(padding+1:end-padding, padding+1:end-padding, :) = input_data;

% 初始化输出矩阵
output = zeros(input_size, input_size);

% 卷积操作 + 饱和处理（最大为128）
for i = 1:input_size
    for j = 1:input_size
        sum_val = 0;
        for c = 1:num_channels
            region = padded_input(i:i+kernel_size-1, j:j+kernel_size-1, c);
            sum_val = sum_val + sum(sum(region .* kernel_weights(:, :, c)));
        end
        % 饱和裁剪：最大值不超过128
        sum_val = min(sum_val, 128);
        output(i, j) = sum_val;
    end
end

% 打印卷积输出结果
disp('--- 卷积输出结果矩阵（裁剪后） ---');
disp(output);
