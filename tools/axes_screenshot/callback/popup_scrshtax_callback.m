function popup_scrshtax_callback(hObject, ~)
% popup_scrshtax_callback is an internal function of fMROI.
% Updates the suggested slice range when switching target axis.
%
% Syntax:
%   popup_scrshtax_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure or control.
%
% Author: Andre Peres, 2026, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);

if ~isfield(st, 'vols') || isempty(st.vols)
    return;
end

if isfield(handles, 'table_selectedcell') && ~isempty(handles.table_selectedcell)
    n = handles.table_selectedcell(1);
else
    n = find(~cellfun(@isempty, st.vols), 1, 'last');
end

if isempty(n) || n == 0 || n > length(st.vols) || isempty(st.vols{n})
    n = 1;
end

if isempty(st.vols{n})
    return;
end

v = get(handles.popup_scrshtax, 'Value');
[~, ax_dim] = max(abs(st.vols{n}.mat(1:3, 1:3)), [], 2);
switch v
    case 1, target_col = ax_dim(3); % Axial
    case 2, target_col = ax_dim(2); % Coronal
    case 3, target_col = ax_dim(1); % Sagittal
end

max_slice = st.vols{n}.dim(target_col);

if isfield(handles, 'edit_mosaiclastslice') && ishandle(handles.edit_mosaiclastslice)
    set(handles.edit_mosaiclastslice, 'String', num2str(max_slice));
end

if isfield(handles, 'edit_scrshtlastslice') && ishandle(handles.edit_scrshtlastslice)
    set(handles.edit_scrshtlastslice, 'String', num2str(max_slice));
end

guidata(hObject, handles);
