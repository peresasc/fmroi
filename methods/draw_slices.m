function draw_slices(hObject, ~)
% draw_slices is an internal function of fMROI.
%
% Syntax:
%   draw_slices(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);

if ~isfield(st, 'vols') || isempty(st.vols)
    return;
end

n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
if isempty(n_image)
    return;
end

bb   = st.bb;
Dims = round(diff(bb)'+1);
is   = inv(st.Space);
cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);

TD = Dims([1 2]);
CD = Dims([1 3]);
if st.mode == 0
    SD = Dims([3 2]);
else
    SD = Dims([2 3]);
end

rgb_composite = cell(1, 3);
alpha_composite = cell(1, 3);

for i = 1:n_image
    if ~handles.imgprop(i).viewslices
        continue;
    end
    
    slices = getslices(st, i);
    
    % Colormap for image i
    if ~isfield(handles.imgprop(i), 'cmap') || isempty(handles.imgprop(i).cmap)
        if isfield(handles, 'popup_colormap')
            s = get(handles.popup_colormap, 'String');
            v = handles.imgprop(i).colormap;
            if v > 0 && v <= length(s)
                cmap_name = s{v};
                if ischar(cmap_name) && ~strcmpi(cmap_name, 'custom') && ~strcmpi(cmap_name, 'colorlut')
                    try
                        handles.imgprop(i).cmap = feval(cmap_name, 256);
                    catch
                        handles.imgprop(i).cmap = gray(256);
                    end
                else
                    handles.imgprop(i).cmap = gray(256);
                end
            else
                handles.imgprop(i).cmap = gray(256);
            end
        else
            handles.imgprop(i).cmap = gray(256);
        end
    end
    cmap_i = handles.imgprop(i).cmap;
    
    cmin_color = handles.imgprop(i).mincolor * (st.vols{i}.clim(2) - st.vols{i}.clim(1)) + st.vols{i}.clim(1);
    cmax_color = handles.imgprop(i).maxcolor * (st.vols{i}.clim(2) - st.vols{i}.clim(1)) + st.vols{i}.clim(1);
    if cmin_color == cmax_color
        cmax_color = cmin_color + eps;
    end
    
    minthrs = handles.imgprop(i).minthrs * (st.vols{i}.clim(2) - st.vols{i}.clim(1)) + st.vols{i}.clim(1);
    maxthrs = handles.imgprop(i).maxthrs * (st.vols{i}.clim(2) - st.vols{i}.clim(1)) + st.vols{i}.clim(1);
    alphavalue = handles.imgprop(i).alpha;
    
    for j = 1:3
        if isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'hbrush') && ...
                ishandle(handles.drawingroi.hbrush) && isfield(handles.drawingroi, 'ucidx') && ...
                isfield(handles.drawingroi, 'selaxis') && i == handles.drawingroi.ucidx && j == handles.drawingroi.selaxis
            continue;
        end
        
        slice2d = slices{j};
        
        if minthrs <= maxthrs
            slicemask = slice2d >= minthrs & slice2d <= maxthrs;
        else
            slicemask = slice2d >= minthrs | slice2d <= maxthrs;
        end
        
        alpha2d = zeros(size(slice2d));
        alpha2d(slicemask) = alphavalue;
        alpha3d = repmat(alpha2d, [1, 1, 3]);
        
        c = gettruecolor(slice2d, [cmin_color cmax_color], cmap_i);
        
        if isempty(rgb_composite{j})
            rgb_composite{j} = c .* alpha3d;
            alpha_composite{j} = alpha2d;
        else
            rgb_composite{j} = rgb_composite{j} .* (1 - alpha3d) + c .* alpha3d;
            alpha_composite{j} = alpha_composite{j} .* (1 - alpha2d) + alpha2d;
        end
    end
end

for j = 1:3
    if ~isempty(rgb_composite{j})
        set(handles.ax{1, j}.d, 'HitTest', 'off', 'CData', rgb_composite{j}, 'Visible', 'on');
    else
        switch j
            case 1, blank_sz = [TD(2), TD(1), 3];
            case 2, blank_sz = [CD(2), CD(1), 3];
            case 3, blank_sz = [SD(2), SD(1), 3];
        end
        set(handles.ax{1, j}.d, 'HitTest', 'off', 'CData', zeros(blank_sz), 'Visible', 'on');
    end
end

% Update the axial slice in axes 4 (3D)
if isfield(handles.ax{1, 4}, 'd') && ishandle(handles.ax{1, 4}.d)
    pos = st.Space\[st.centre,1]'-[st.bb(1,:)-1,1]';
    p3 = pos(3);
    z = p3*ones(size(handles.ax{1,4}.d.ZData));
    handles.ax{1,4}.d.ZData = z;
    if ~isempty(rgb_composite{1})
        handles.ax{1,4}.d.CData = rgb_composite{1};
        handles.ax{1,4}.d.AlphaData = alpha_composite{1};
    else
        handles.ax{1,4}.d.CData = zeros([size(z), 3]);
        handles.ax{1,4}.d.AlphaData = zeros(size(z));
    end
    set(handles.ax{1,4}.d, 'FaceAlpha', 'flat', 'FaceColor', 'flat', ...
        'EdgeColor', 'none', 'alphadatamapping', 'none', 'Visible', 'on');
end

set(handles.ax{1,1}.lx,'HitTest','off',...
    'Xdata',[0 TD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
set(handles.ax{1,1}.ly,'HitTest','off',...
    'Ydata',[0 TD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));

set(handles.ax{1,1}.txy,'HitTest','off',...
    'Position', [cent(1)-bb(1,1)+1, cent(2)-bb(1,2)+1]);


set(handles.ax{1,2}.lx,'HitTest','off',...
    'Xdata',[0 CD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
set(handles.ax{1,2}.ly,'HitTest','off',...
    'Ydata',[0 CD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));

set(handles.ax{1,2}.txy,'HitTest','off',...
    'Position', [cent(1)-bb(1,1)+1, cent(3)-bb(1,3)+1]);

if st.mode == 0
    set(handles.ax{1,3}.lx,'HitTest','off',...
        'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
    set(handles.ax{1,3}.ly,'HitTest','off',...
        'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(cent(3)-bb(1,3)+1));
    
    set(handles.ax{1,3}.txy,'HitTest','off',...
    'Position', [cent(3)-bb(1,3)+1, cent(2)-bb(1,2)+1]);
else
    set(handles.ax{1,3}.lx,'HitTest','off',...
        'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
    set(handles.ax{1,3}.ly,'HitTest','off',...
        'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(bb(2,2)+1-cent(2)));
    
    set(handles.ax{1,3}.txy,'HitTest','off',...
    'Position', [bb(2,2)+1-cent(2), cent(3)-bb(1,3)+1]);
end
guidata(hObject, handles);
drawnow;

