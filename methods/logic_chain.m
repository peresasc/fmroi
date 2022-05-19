function datachain = logic_chain(data,op)
% logic_chain performs consecutive logical operations.
% Ex: data = {A;B;C;D}; op = {'AND';'OR';'XOR'}
%     datachain = xor(or(and(A,B),C),D);
%
% Syntax:
%   datachain = logic_chain(data,op)
%
% Inputs:
%        data: mx1 cell array containing in each cell a numeric array or
%              string with the path to a nifti file (*.nii).All arrays 
%              (including nifti file data arrays) must have the same size.
%          op: (m-1)x1 cell array containing in each cell a string with the
%              logical operator. If op has more than m-1 lines, the lines
%              that exceed will be disregarded.
%
% Outputs:
%   datachain: Numerical matrix with the same size as the input matrices.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if ischar(data{1})
    auxdata = cell(length(data),1);
    for i = 1:length(data)
        vol = spm_vol(data{i});
        auxdata{i} = spm_data_read(vol);
    end
    clear data
    data = auxdata;
end

datachain = data{1};


for i = 1:length(data)-1
    
    switch lower(op{i})
        
        case 'and'
            datachain = and(datachain,data{i+1});
            
        case 'or'
            datachain = or(datachain,data{i+1});
            
        case 'not'
            datachain = and(datachain,not(data{i+1}));
            
        case 'xor'
            datachain = xor(datachain,data{i+1});
            
        case 'nand'
            datachain = not(and(datachain,data{i+1}));
            
        case 'nor'
            datachain = not(or(datachain,data{i+1}));
    end
   
end