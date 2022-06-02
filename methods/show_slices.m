function show_slices(hObject,fn)
% show_slices is an internal function of fMROI.
%
% Syntax:
%   show_slices(hObject,fn)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%        fn: Full path of the nifti file to be displayed.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

set(handles.panel_control,'Visible','on');
set(handles.menuview_showctrlpanel,'Enable','on')

st = stgen(fn,st);

n_image = find(~cellfun(@isempty,st.vols), 1, 'last');

st.vols{n_image}.clim = [min(st.vols{n_image}.private.dat(:)),...
                        max(st.vols{n_image}.private.dat(:))];
                    
                    
axes_pos = zeros(4);
axes_pos(1,:) = [0, 0, 0.5, 0.5];
axes_pos(2,:) = [0, .5, 0.5, 0.5];
axes_pos(3,:) = [.5, .5, 0.5, 0.5];
axes_pos(4,:) = [.5, 0, 0.5, 0.5];
          

axtags{1} = ['transversal_', num2str(n_image)];
axtags{2} = ['coronal_', num2str(n_image)];
axtags{3} = ['sagital_', num2str(n_image)];
axtags{4} = ['rendering_', num2str(n_image)];
         
% deletes the cursor
if n_image > 1
    for j = 1:n_image-1
        for v = 1:3
            delete(handles.ax{j,v}.lx);
            handles.ax{j,v}.lx = [];
            delete(handles.ax{j,v}.ly);
            handles.ax{j,v}.ly = [];
        end
    end    
end

maxdim = max(round(diff(st.bb)+1));

for i = 1:4
    if i == 4
        if n_image == 1
            ax = axes('Parent', handles.panel_graph,...
                'Position',axes_pos(i,:), 'Box', 'off', 'Units', 'normalized','XTick', [],'YTick', []);
            set(ax,'Visible','off', 'Ydir','normal',...
                'CameraTargetMode','manual','view',[-35 35]);
            st.dims = round(diff(st.bb)'+1);
            set(ax,'Xlim',[0 st.dims(1)],'Ylim',[0 st.dims(2)],'Zlim',[0 st.dims(3)])
            handles.hrotate = rotate3d(ax);
            handles.hrotate.Enable = 'off';

            hold(ax,'on')
            handles.ax{n_image,i} = struct('ax',ax);
        end
        ax = handles.ax{1,4}.ax;
        set(ax,'Tag',axtags{i});
                
        slices = getslices(st,n_image);
        
        % Current position to display (cpdpl): converts the position 
        % in the scanner coordinates (st.centre in mm) to display 
        % coordinates (st.Space in isovoxel units).
        cpdpl = st.Space\[st.centre,1]'-[st.bb(1,:)-1,1]'; % A\B == inv(A)*B
              
        [x,y,z] = meshgrid(1:size(slices{1},2),1:size(slices{1},1),cpdpl(3));
        c = gettruecolor(slices{1},st.vols{1}.private.dat(:,:,:),ax.Colormap);
        d  = surface('Parent',ax,'XData',x,'YData',y,'ZData',z,'CData',c,...
            'FaceColor','flat','EdgeColor','none');
       
        handles.ax{n_image,i} = struct('ax',ax,'d',d);

    else
    ax = axes('Parent', handles.panel_graph,...
        'Position',axes_pos(i,:), 'Box', 'off', 'Units', 'normalized','XTick', [],'YTick', []);
    d  = imagesc(0, 'Tag',['img_',axtags{i}], 'Parent',ax);
    
    set(ax, 'Ydir','normal','XLimMode', 'auto', 'YLimMode', 'auto',...
        'XTick', [],'YTick', [], 'Tag', axtags{i},...
        'ButtonDownFcn', @axes_buttondownfcn_callback, 'Color', 'none','XColor','none','YColor','none');
    
    colormap(ax,'gray');
    caxis(st.vols{n_image}.clim);
    
    axis([0 maxdim 0 maxdim])
    axis equal
    
    lx = line(0,0, 'Parent',ax, 'Color',[1 0 0]); % Draw horizontal line cursor
    ly = line(0,0, 'Parent',ax, 'Color',[1 0 0]); % Draw vertical line cursor
    
    txy = text(0, 0, '+', 'Parent', ax, 'Color',[1 0 0],...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    set(txy,'Visible','off')
    
    handles.ax{n_image,i} = struct('ax',ax,'d',d,'lx',lx,'ly',ly,'txy',txy);
    end
end

tleftpos = {[0,.2,.05,.05],'L';...
            [0,.7,.05,.05],'L';...
            [.5,.7,.05,.05],'A'};
        
trightpos = {[.45,.2,.05,.05],'R';...
            [.45,.7,.05,.05],'R';...
            [.95,.7,.05,.05],'P'};

if ~isfield(handles,'axannot')
    for i = 1:3
        handles.axannot(i,1) = annotation(handles.panel_graph,'textbox',...
            'Position',tleftpos{i,1},'String',tleftpos{i,2},...
            'Color','w','FitBoxToText','on','LineStyle','none');
        
        handles.axannot(i,2) = annotation(handles.panel_graph,'textbox',...
            'Position',trightpos{i,1},'String',trightpos{i,2},...
            'Color','w','FitBoxToText','on','LineStyle','none');
    end
end

s = get(handles.popup_colormap,'String');

for v = 1:length(s)
    if strcmp(s(v),'gray')
        break
    end
end

%--------------------------------------------------------------------------
% Generate handles.imgprop fields

imgmin_str = sprintf('%0.2g',st.vols{n_image}.clim(1));
imgmin_str(imgmin_str=='+')=[];

imgmax_str = sprintf('%0.2g',st.vols{n_image}.clim(2));
pexp = find(imgmax_str=='e');
if isempty(pexp)
    imgmax_alg = imgmax_str;
    imgmax_exp = '';
else
    imgmax_alg = imgmax_str(1:pexp-1);
    imgmax_exp = imgmax_str(pexp:end);
    imgmax_exp(imgmax_exp=='+')=[];
end

alphamin_str = num2str(handles.slider_alpha.Min);
alphamax_str = num2str(handles.slider_alpha.Max);
renderalphamin_str = num2str(handles.slider_roialpha.Min);
renderalphamax_str = num2str(handles.slider_roialpha.Max);

handles.imgprop(n_image).viewslices = 1;
handles.imgprop(n_image).viewrender = 0;
handles.imgprop(n_image).colormap = v;
handles.imgprop(n_image).roicolor = 1;

handles.imgprop(n_image).minthrs = handles.slider_minthrs.Min;
handles.imgprop(n_image).maxthrs = handles.slider_maxthrs.Max;
handles.imgprop(n_image).alpha = handles.slider_alpha.Max;
handles.imgprop(n_image).roialpha = handles.slider_roialpha.Max;
handles.imgprop(n_image).mincolor = handles.slider_mincolor.Min;
handles.imgprop(n_image).maxcolor = handles.slider_maxcolor.Max;

handles.imgprop(n_image).alphamin_str = alphamin_str;
handles.imgprop(n_image).alphamax_str = alphamax_str;
handles.imgprop(n_image).renderalphamin_str = renderalphamin_str;
handles.imgprop(n_image).renderalphamax_str = renderalphamax_str;
handles.imgprop(n_image).imgmin_str = imgmin_str;
handles.imgprop(n_image).imgmax_alg = imgmax_alg;
handles.imgprop(n_image).imgmax_exp = imgmax_exp;

%--------------------------------------------------------------------------
% Update table_listimg

cbox = cell(n_image,1);
vval = cell(n_image,1);
fn = cell(n_image,1);

for i = 1:n_image
    cbox{i} = logical(handles.imgprop(i).viewslices);
    
    cp = st.vols{i}.mat\[st.centre';1];
    cp = round(cp(1:3))';
    vval{i} = st.vols{i}.private.dat(cp(1),cp(2),cp(3));
    
    [~,auxfn,ext] = fileparts(st.vols{i}.fname);
    fname = [auxfn, ext];
    fn{i} = fname;
end

tdata = [cbox,vval,fn];
set(handles.table_listimg,'Data',tdata);

if isfield(handles,'table_selectedcell')
    evData.Indices = handles.table_selectedcell;
else
    evData.Indices = [1,3];
end

guidata(hObject, handles);
table_listimg_selcallback(hObject, evData)
handles = guidata(hObject);


%--------------------------------------------------------------------------
% Update edit_pos

% st.centre - current position in the scanner coordinates in mm.
% cpima - current position in the image coordinates in voxels.
% cpdpl - current position in the display coordinates.

if n_image == 1
    cpima = st.vols{1}.mat\[st.centre';1]; % A\B == inv(A)*B
    cpima = round(cpima(1:3))';
    cpall = [st.centre; cpima];  
    
    for i = 1:2
        for j = 1:3
            set(handles.edit_pos(i,j),'String',num2str(cpall(i,j)))
        end
    end
end

% update_coordinates(hObject)
%--------------------------------------------------------------------------

guidata(hObject, handles);
updateuicontrols(hObject,n_image);
handles = guidata(hObject);

if ~isfield(handles,'tabgp')
    guidata(hObject, handles);
    create_panel_roi(hObject);
    handles = guidata(hObject);
end

if ~get(handles.tbutton_lcsrcsel,'Value')
    guidata(hObject,handles);
    imgnamelist = getimgnamelist(hObject);
    set(handles.popup_lcmask,'String',imgnamelist)
    guidata(hObject, handles);
end

popup_roitype_callback(hObject);
handles = guidata(hObject);

guidata(hObject, handles);

draw_slices(hObject)