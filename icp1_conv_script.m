%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Digital ASIC Group, EIT, LTH, Lund University
% Author:  Sergio Castillo
% Date:    08/05/2024
% Name:    icp1_conv_script.m
% Version: 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Instructions
% --------------------------------------------- %
% - Use this script to generate the input data and weights to be sent to
% the convolution unit.
% - Change "w_rows" and "w_cols" depending on whether you are working with
% 3x3 or 5x5 convolution.
% - Use a padding such as the number of rows/columns of the ofm is the same
% as the number of rows/columns of the ifm.
% - In HW, all numbers should be represented as positive 8 bits fixed-point
% format, meaning that the range is between 0 and 255, if any ofm value
% goes beyond this range, it must saturate (e.g. 278 -> 255).
%
%
%
% - Use this script as a tool for comparing your simulation results with
% the results obtained in this script. Currently the script generates
% random inputs and weights, you should be able to store the randommly
% generated inputs and weights into a .txt so that you can stimuli your
% design with such data, and so that you can load such data to this script
% later again, rather than generating new random data, for results
% comparison.
% --------------------------------------------- %
%%

% Define the size of the ifm and weights kernel
ifm_rows = 28; % Do not change
ifm_cols = 28; % Do not change
ifm_channels = 3; 

w_rows = 5;
w_cols = 5;
ofm_channels = 1;

% Define padding to be added to input
padding = 2;

% Define stride of the convolution operation (keep to 1)
stride = 1;

% Padding and stride determine 2D dimensions of output feature map
ofm_rows = 2*padding + ifm_rows - (w_rows - 1)*stride;
ofm_cols = 2*padding + ifm_cols - (w_cols - 1)*stride;

% Generate ifm (weights) randomdly with integers between 0 and 3 (5 for weights)
% the range determines the bitsize of the input and weights
% if 8 bits, set it to [0, 255]
ifm = randi([0, 3], ifm_rows, ifm_cols, ifm_channels);
w = randi([0, 5], w_rows, w_cols, ifm_channels, ofm_channels);

ofm = zeros(ofm_rows, ofm_cols, ofm_channels);
for i = 1:ofm_channels
    ofm(:,:,i) = convolution(ifm, w(:,:,:,i), stride, padding);
end

%% Plot
% Before saturation
figure()
histogram(ofm);
figure()
imagesc(ofm);

% After saturation
ofm = min(ofm, 255);
figure()
histogram(ofm);
figure()
imagesc(ofm);

%% Export
% Notice values are exported in column-major order, but feel free to change
% the order as you please.

% ifm
fileID = fopen('ifm.h', 'w');
fprintf(fileID, 'uint8_t ifm[] = {\n');
for ch = 1:size(ifm,3)
    for row = 1:size(ifm,2)
        for col = 1:size(ifm,1)
            if ((col == size(ifm,1)) && (row == size(ifm,2)) && (ch == size(ifm,3)))
                fprintf(fileID, '%d\n', ifm(row, col, ch));
            else
                fprintf(fileID, '%d,\n', ifm(row, col, ch));
            end
        end
    end
end
fprintf(fileID, "};\n");
fclose(fileID);

% weights
fileID = fopen('w.h', 'w');
fprintf(fileID, 'uint8_t w[] = {\n');
for ch = 1:size(w,3)
    for row = 1:size(w,2)
        for col = 1:size(w,1)
            if ((col == size(w,1)) && (row == size(w,2)) && (ch == size(w,3)))
                fprintf(fileID, '%d\n', w(row, col, ch));
            else
                fprintf(fileID, '%d,\n', w(row, col, ch));
            end
        end
    end
end
fprintf(fileID, "};\n");
fclose(fileID);

% weights
fileID = fopen('expected_ofm.h', 'w');
fprintf(fileID, 'uint8_t expected_ofm[] = {\n');
for row = 1:size(ofm,2)
    for col = 1:size(ofm,1)
        if ((col == size(ofm,1)) && (row == size(ofm,2)))
            fprintf(fileID, '%d\n', ofm(row, col));
        else
            fprintf(fileID, '%d,\n', ofm(row, col));
        end
    end
end
fprintf(fileID, "};\n");
fclose(fileID);