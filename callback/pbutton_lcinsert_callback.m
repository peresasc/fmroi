function pbutton_lcinsert_callback(hObject, ~)
% pbutton_lcinsert_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_lcinsert_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

vimg = get(handles.popup_lcmask,'Value');
simg = get(handles.popup_lcmask,'String');
imgname = simg{vimg};

vop = get(handles.popup_lcoperator,'Value');
sop = get(handles.popup_lcoperator,'String');
op = sop{vop};

datatype = get(handles.tbutton_lcsrcsel,'String');

d = get(handles.table_roilc,'Data');

[curr_row, ~] = find(~cellfun(@isempty,d), 1, 'last');
if isempty(curr_row)
    curr_row = 1;
else
    curr_row = curr_row + 1;
end

d{curr_row,1} = imgname;
d{curr_row,2} = op;
d{curr_row,3} = datatype;
set(handles.table_roilc,'Data',d)

guidata(hObject, handles);

