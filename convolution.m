%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Digital ASIC Group, EIT, LTH, Lund University
% Author:  Sergio Castillo
% Date:    08/05/2024
% Name:    convolution.m
% Version: 1
%
%
% Inputs:
%   mat: ifm matrix with dimensions [rows, cols, ifm_channels]
%   fil: filter weights with dimensions [rows, cols, ifm_channels]
%   stride
%   padding
% Outputs:
%   results: ofm matrix with dimension [rows, cols]
%
% Notes:
%    This function performs a 2D convolution. For a 3D convolution, embed
%    the function within a loop:
%
% >>           for i = 1:ofm_channels
% >>               ofm(:,:,i) = convolution(ifm, w(:,:,:,i), stride, padding);
% >>           end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [results] = convolution(mat, fil, stride, padding)
    global mac_count
    if (padding > 0)
        mat_pad = padarray(mat, [padding padding 0], 0, 'both');
        p = padding;
    else
        mat_pad = mat;
        p = 0;
    end
    
    dim_result_w = int8(((size(mat,1) - size(fil,1)+(2*p))/stride)+1);
    dim_result_h = int8(((size(mat,2) - size(fil,1)+(2*p))/stride)+1);

    filetered = zeros(size(fil,1),size(fil,2)); % slide matrix of size (k_row,k_col) of filter
    results_ch = zeros(dim_result_w, dim_result_h,size(fil,3)); % conv of each channel stored here
    results = zeros(dim_result_w, dim_result_h); %convs of each channel added up together here

    for ch = 1:size(fil,3)
        for row = 1:dim_result_w
            for col = 1:dim_result_h
                spot = mat_pad(row:row+size(fil,1)-1, col:col+size(fil,2)-1, ch);
                for k_row = 1:size(fil,2)
                    for k_col = 1:size(fil,1)
                        filetered(k_row,k_col) = spot(k_row,k_col) * fil(k_row, k_col, ch);
                        mac_count = mac_count + 1;
                    end
                end

                result = sum(filetered, 'all');
                results_ch(row, col, ch) = result;
            end
        end
    end
    for i = 1:size(results_ch,3)
        results = results + results_ch(:,:,i);
    end
end
