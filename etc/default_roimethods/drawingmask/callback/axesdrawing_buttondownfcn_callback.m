function axesdrawing_buttondownfcn_callback(hObject,event)
% axesdrawing_buttondownfcn_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);
h = getoverobj('type','axes');

if isempty(h)
    return;
end

tag = get(h,'Tag');
if length(tag) >= 2
    tag = tag(1:end-2);
end
if strcmpi(tag,'transversal')
    tag = 'axial';
elseif strcmpi(tag,'sagital')
    tag = 'sagittal';
end

v = handles.popup_workingaxes.Value;
s = handles.popup_workingaxes.String;
waxis = s{v};

if strcmpi(waxis,tag)
    if (strcmpi(event.EventName,'WindowMouseMotion') && handles.mousehold && ...
            ~isempty(h) && not(handles.toolbar)) || ...
            strcmp(event.EventName,'Hit')

        listimgdata = get(handles.table_listimg,'Data');
        ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);
        if isempty(ucidx)
            ucidx = find(~cellfun(@isempty,st.vols), 1, 'last');
        end
        selaxis = get(handles.popup_workingaxes,'Value');
        wroi = get(handles.popup_workingroi,'Value')-1;
        datalut = get(handles.table_roilut,'Data');

        % Ensure drawingroi structure is present
        if ~isfield(handles, 'drawingroi')
            handles.drawingroi = struct();
        end

        % Check if brush overlay and mask exist and match current selaxis
        if ~isfield(handles.drawingroi, 'brushmask') || isempty(handles.drawingroi.brushmask) || ...
                ~isfield(handles.drawingroi, 'selaxis') || handles.drawingroi.selaxis ~= selaxis || ...
                ~isfield(handles.drawingroi, 'hbrush') || ~ishandle(handles.drawingroi.hbrush)
            
            if isfield(handles.drawingroi, 'hbrush') && ishandle(handles.drawingroi.hbrush)
                delete(handles.drawingroi.hbrush);
            end
            
            slices = getslices(st, ucidx);
            mask2d = slices{selaxis};
            handles.drawingroi.brushmask = mask2d;
            handles.drawingroi.selaxis = selaxis;
            handles.drawingroi.wroi = wroi;
            handles.drawingroi.ucidx = ucidx;

            overlay_rgb = zeros(size(mask2d, 1), size(mask2d, 2), 3);
            alpha2d = zeros(size(mask2d));
            alphavalue = handles.imgprop(ucidx).alpha;
            if isempty(alphavalue) || alphavalue == 0
                alphavalue = 0.5;
            end

            for k = 1:size(datalut, 1)
                k_val = datalut{k, 1};
                if iscell(k_val), k_val = k_val{1}; end
                r_k = datalut{k, 3}; if ischar(r_k), r_k = str2double(r_k); end
                g_k = datalut{k, 4}; if ischar(g_k), g_k = str2double(g_k); end
                b_k = datalut{k, 5}; if ischar(b_k), b_k = str2double(b_k); end
                k_color = double([r_k, g_k, b_k]) / 255;
                k_mask = (mask2d == k_val);
                if any(k_mask(:))
                    overlay_rgb(:,:,1) = overlay_rgb(:,:,1) + k_color(1) * k_mask;
                    overlay_rgb(:,:,2) = overlay_rgb(:,:,2) + k_color(2) * k_mask;
                    overlay_rgb(:,:,3) = overlay_rgb(:,:,3) + k_color(3) * k_mask;
                    alpha2d(k_mask) = alphavalue;
                end
            end

            r_w = datalut{wroi, 3}; if ischar(r_w), r_w = str2double(r_w); end
            g_w = datalut{wroi, 4}; if ischar(g_w), g_w = str2double(g_w); end
            b_w = datalut{wroi, 5}; if ischar(b_w), b_w = str2double(b_w); end
            active_color = double([r_w, g_w, b_w]) / 255;

            handles.drawingroi.overlay_rgb = overlay_rgb;
            handles.drawingroi.active_color = active_color;

            handles.drawingroi.hbrush = image('Parent', handles.ax{1, selaxis}.ax, ...
                'CData', overlay_rgb, 'AlphaData', alpha2d, ...
                'HitTest', 'off', 'PickableParts', 'none');

            uistack(handles.ax{1, selaxis}.d, 'bottom');
            if isfield(handles.ax{1, selaxis}, 'lx') && ishandle(handles.ax{1, selaxis}.lx)
                uistack(handles.ax{1, selaxis}.lx, 'top');
            end
            if isfield(handles.ax{1, selaxis}, 'ly') && ishandle(handles.ax{1, selaxis}.ly)
                uistack(handles.ax{1, selaxis}.ly, 'top');
            end
            draw_slices(hObject);
        end

        cp = get(h,'CurrentPoint');
        cp = round(cp(1,1:2));
        mask = handles.drawingroi.brushmask;

        r = str2double(get(handles.edit_brushradius,'String'));
        if isnan(r) || r < 1
            r = 1;
        end
        [x,y] = size(mask);
        [My,Mx] = ndgrid(1:x,1:y);
        auxmask = (sqrt((Mx-cp(1)).^2 + (My-cp(2)).^2) < r);

        r_w = datalut{wroi, 3}; if ischar(r_w), r_w = str2double(r_w); end
        g_w = datalut{wroi, 4}; if ischar(g_w), g_w = str2double(g_w); end
        b_w = datalut{wroi, 5}; if ischar(b_w), b_w = str2double(b_w); end
        active_color = double([r_w, g_w, b_w]) / 255;

        overlay_rgb = handles.drawingroi.overlay_rgb;
        alpha2d = get(handles.drawingroi.hbrush, 'AlphaData');
        alphavalue = handles.imgprop(ucidx).alpha;
        if isempty(alphavalue) || alphavalue == 0
            alphavalue = 0.5;
        end

        roi_val = datalut{wroi, 1};
        if iscell(roi_val), roi_val = roi_val{1}; end

        if handles.mousehold == 1
            mask(auxmask) = roi_val;
            
            c_r = overlay_rgb(:,:,1); c_r(auxmask) = active_color(1); overlay_rgb(:,:,1) = c_r;
            c_g = overlay_rgb(:,:,2); c_g(auxmask) = active_color(2); overlay_rgb(:,:,2) = c_g;
            c_b = overlay_rgb(:,:,3); c_b(auxmask) = active_color(3); overlay_rgb(:,:,3) = c_b;
            
            alpha2d(auxmask) = alphavalue;
        else
            mask(auxmask) = 0;
            alpha2d(auxmask) = 0;
        end

        handles.drawingroi.brushmask = mask;
        handles.drawingroi.overlay_rgb = overlay_rgb;
        
        set(handles.drawingroi.hbrush, 'CData', overlay_rgb, 'AlphaData', alpha2d);
    end
end

% %--------------------------------------------------------------------------
% % update current position mousemove
if ~isempty(h)
    n = handles.table_selectedcell(1);
    centre = getworldpos(h);
    cpima = st.vols{n}.mat\[centre';1];
    cpima = round(cpima(1:3))';

    set(handles.text_pos(1),'String',num2str(round(centre)))
    set(handles.text_pos(2),'String',num2str(cpima))
end

guidata(hObject, handles);