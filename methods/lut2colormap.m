function [cmap,idx] = lut2colormap(lutpath)
% lut2colormap converts the information from color Lookup tables to RGB
% colormaps in such way that it can be called by the matlab command
% "colormap". The color LUT table must have the fields: 1. 'No' or 'Index';
% 2. 'Label_Name'; 3. 'R'; 4. 'G'; 5. 'B'. Ex:
%
% No/Index    Label_Name     R    G    B
% 0           label_1        0.0  0.0  0.0
% 1           label_2        0.1  0.1  0.1
% n           label_n        r_n  g_n  b_n
%
% Syntax:
%   [cmap,idx] = lut2colormap(lutpath)
%
% Inputs:
%   lutpath: Path to the color LUT file that can be a ASCII or mat-file.
%
% Outputs:
%      cmap: mx3 RGB colormap matrix with values between 0 to 1.
%       idx: mx1 vector containing the color LUT indexes.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

[~,~,ext] = fileparts(lutpath);
if strcmpi(ext,'.mat')
    auxcmap = load(lutpath);
    auxfield = fieldnames(auxcmap);
    lut = auxcmap.(auxfield{1});
else
    lut = readtable(lutpath);
end

i = 1;
r = size(lut,2) - 2;
g = size(lut,2) - 1;
b = size(lut,2);

if find(strcmp('No',lut.Properties.VariableNames),1)
    i = find(strcmp('No',lut.Properties.VariableNames),1);
end

if find(strcmp('Index',lut.Properties.VariableNames),1)
    i = find(strcmp('Index',lut.Properties.VariableNames),1);
end

if find(strcmp('R',lut.Properties.VariableNames),1)
    r = find(strcmp('R',lut.Properties.VariableNames),1);
end

if find(strcmp('G',lut.Properties.VariableNames),1)
    g = find(strcmp('G',lut.Properties.VariableNames),1);
end

if find(strcmp('B',lut.Properties.VariableNames),1)
    b = find(strcmp('B',lut.Properties.VariableNames),1);
end

idx = (0:max(lut{:,i}))';
cmap = zeros(max(lut{:,i})+1,3);
for j = 0:max(lut{:,1})
    a = find(lut{:,i}==j,1);
    if ~isempty(a)
        cmap(j+1,:) = [lut{a,r},lut{a,g},lut{a,b}];
    end
end
cmap = cmap/255;