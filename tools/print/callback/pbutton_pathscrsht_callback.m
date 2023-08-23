function pbutton_pathscrsht_callback(hObject,~)
% pbutton_pathscrsht_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_pathscrsht_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 23/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
extfilt = {'*.png';'*.jpeg';'*.bmp';'*.gif';'*.tif';'*.ras'};
[fn,pn,idx] = uiputfile(extfilt,'Select file name','fmroiscreenshot.png');
if ~idx
    return
end

set(handles.edit_outscrshtpath,'String',fullfile(pn,fn));

guidata(hObject,handles)