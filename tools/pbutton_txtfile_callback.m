function pbutton_txtfile_callback(fig,~)
% pbutton_txtfile_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_txtfile_callback(fig,~)
%
% Inputs:
%   fig: figure that contains the diplayed header.
%
% Author: Fer Ponce, 2022.
% Last update: Fer Ponce, 28/07/2022, peres.asc@gmail.com

handles = guidata(fig);

namename = handles.ImgTitle;
txtFILE_name = sprintf('%s_header.txt',namename); %fill with the desired image

[file,path,~] = uiputfile(txtFILE_name);
info_table= handles.InfoTable;

writetable(info_table,txtFILE_name);

if exist(fullfile(path,file))
    f = msgbox("Done!");
end
