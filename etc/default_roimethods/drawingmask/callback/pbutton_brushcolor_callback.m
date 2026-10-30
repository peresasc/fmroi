function pbutton_brushcolor_callback(hObject,~)
% pbutton_brushcolor_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2026, peres.asc@gmail.com
% Last update: Andre Peres, 29/10/2026, peres.asc@gmail.com

handles = guidata(hObject);

% Read current color from edits as starting color for uisetcolor
r = str2double(get(handles.edit_brushcolor_r, 'String'));
g = str2double(get(handles.edit_brushcolor_g, 'String'));
b = str2double(get(handles.edit_brushcolor_b, 'String'));

if isnan(r) || r < 0, r = 0; elseif r > 255, r = 255; end
if isnan(g) || g < 0, g = 0; elseif g > 255, g = 255; end
if isnan(b) || b < 0, b = 0; elseif b > 255, b = 255; end

init_color = [r, g, b] / 255;

c = uisetcolor(init_color, 'Select Brush Color');

% If user cancelled, c will equal 0
if isequal(c, 0)
    return;
end

rgb255 = round(c * 255);
rgb255 = min(max(rgb255, 0), 255);

set(handles.edit_brushcolor_r, 'String', num2str(rgb255(1)));
set(handles.edit_brushcolor_g, 'String', num2str(rgb255(2)));
set(handles.edit_brushcolor_b, 'String', num2str(rgb255(3)));

if isfield(handles, 'panel_brushcolor') && ishandle(handles.panel_brushcolor)
    set(handles.panel_brushcolor, 'BackgroundColor', double(rgb255)/255);
end

% If brush is currently active, update drawingroi.active_color and refresh overlay
if isfield(handles, 'tbutton_brushroidraw') && handles.tbutton_brushroidraw.Value == 1 && ...
        isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'hbrush') && ...
        ishandle(handles.drawingroi.hbrush)
    active_color = double(rgb255) / 255;
    handles.drawingroi.active_color = active_color;
    
    % Update existing overlay colors for the active working ROI
    if isfield(handles.drawingroi, 'brushmask') && isfield(handles.drawingroi, 'wroi')
        wroi = handles.drawingroi.wroi;
        datalut = get(handles.table_roilut, 'Data');
        roi_val = datalut{wroi, 1};
        if iscell(roi_val), roi_val = roi_val{1}; end
        
        roi_mask = (handles.drawingroi.brushmask == roi_val);
        if any(roi_mask(:))
            overlay_rgb = handles.drawingroi.overlay_rgb;
            c_r = overlay_rgb(:,:,1); c_r(roi_mask) = active_color(1); overlay_rgb(:,:,1) = c_r;
            c_g = overlay_rgb(:,:,2); c_g(roi_mask) = active_color(2); overlay_rgb(:,:,2) = c_g;
            c_b = overlay_rgb(:,:,3); c_b(roi_mask) = active_color(3); overlay_rgb(:,:,3) = c_b;
            handles.drawingroi.overlay_rgb = overlay_rgb;
            set(handles.drawingroi.hbrush, 'CData', overlay_rgb);
        end
    end
end

guidata(hObject, handles);
