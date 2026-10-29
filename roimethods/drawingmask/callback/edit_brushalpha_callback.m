function edit_brushalpha_callback(hObject,~)
% edit_brushalpha_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2026, peres.asc@gmail.com
% Last update: Andre Peres, 29/10/2026, peres.asc@gmail.com

handles = guidata(hObject);

alpha_val = str2double(get(handles.edit_brushalpha, 'String'));
if isnan(alpha_val) || alpha_val < 0
    alpha_val = 0;
elseif alpha_val > 1
    alpha_val = 1;
end

set(handles.edit_brushalpha, 'String', num2str(alpha_val));

% If brush is currently active, update drawingroi.alphavalue and refresh overlay
if isfield(handles, 'tbutton_brushroidraw') && handles.tbutton_brushroidraw.Value == 1 && ...
        isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'hbrush') && ...
        ishandle(handles.drawingroi.hbrush)
    handles.drawingroi.alphavalue = alpha_val;
    
    if isfield(handles.drawingroi, 'brushmask') && isfield(handles.drawingroi, 'wroi')
        wroi = handles.drawingroi.wroi;
        datalut = get(handles.table_roilut, 'Data');
        roi_val = datalut{wroi, 1};
        if iscell(roi_val), roi_val = roi_val{1}; end
        
        roi_mask = (handles.drawingroi.brushmask == roi_val);
        if any(roi_mask(:))
            alpha2d = get(handles.drawingroi.hbrush, 'AlphaData');
            alpha2d(roi_mask) = alpha_val;
            set(handles.drawingroi.hbrush, 'AlphaData', alpha2d);
        end
    end
end

guidata(hObject, handles);
