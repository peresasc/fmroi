function edit_brushcolor_callback(hObject,~)
% edit_brushcolor_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2026, peres.asc@gmail.com
% Last update: Andre Peres, 29/10/2026, peres.asc@gmail.com

handles = guidata(hObject);

r = str2double(get(handles.edit_brushcolor_r, 'String'));
g = str2double(get(handles.edit_brushcolor_g, 'String'));
b = str2double(get(handles.edit_brushcolor_b, 'String'));

if isnan(r) || r < 0, r = 0; elseif r > 255, r = 255; else, r = round(r); end
if isnan(g) || g < 0, g = 0; elseif g > 255, g = 255; else, g = round(g); end
if isnan(b) || b < 0, b = 0; elseif b > 255, b = 255; else, b = round(b); end

set(handles.edit_brushcolor_r, 'String', num2str(r));
set(handles.edit_brushcolor_g, 'String', num2str(g));
set(handles.edit_brushcolor_b, 'String', num2str(b));

rgb_norm = [r, g, b] / 255;

if isfield(handles, 'panel_brushcolor') && ishandle(handles.panel_brushcolor)
    set(handles.panel_brushcolor, 'BackgroundColor', rgb_norm);
end

% If brush is currently active, update drawingroi.active_color and refresh overlay
if isfield(handles, 'tbutton_brushroidraw') && handles.tbutton_brushroidraw.Value == 1 && ...
        isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'hbrush') && ...
        ishandle(handles.drawingroi.hbrush)
    handles.drawingroi.active_color = rgb_norm;
    
    if isfield(handles.drawingroi, 'brushmask') && isfield(handles.drawingroi, 'wroi')
        wroi = handles.drawingroi.wroi;
        datalut = get(handles.table_roilut, 'Data');
        roi_val = datalut{wroi, 1};
        if iscell(roi_val), roi_val = roi_val{1}; end
        
        roi_mask = (handles.drawingroi.brushmask == roi_val);
        if any(roi_mask(:))
            overlay_rgb = handles.drawingroi.overlay_rgb;
            c_r = overlay_rgb(:,:,1); c_r(roi_mask) = rgb_norm(1); overlay_rgb(:,:,1) = c_r;
            c_g = overlay_rgb(:,:,2); c_g(roi_mask) = rgb_norm(2); overlay_rgb(:,:,2) = c_g;
            c_b = overlay_rgb(:,:,3); c_b(roi_mask) = rgb_norm(3); overlay_rgb(:,:,3) = c_b;
            handles.drawingroi.overlay_rgb = overlay_rgb;
            set(handles.drawingroi.hbrush, 'CData', overlay_rgb);
        end
    end
end

guidata(hObject, handles);
