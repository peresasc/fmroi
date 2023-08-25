function mosaic(hObject)
% mosaic is an internal function of fMROI.
%
% Syntax:
%   mosaic(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 22/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

%--------------------------------------------------------------------------
% delete panel_graphmulti
if isfield(handles,'panel_graphmulti')
    if isobject(handles.panel_graphmulti)
        if isvalid(handles.panel_graphmulti)
            delete(handles.panel_graphmulti)
        end
    end
    handles = updatehandles(handles);
end

%--------------------------------------------------------------------------
% generate a new blank panel_graphmulti
panelgraph_pos = [0.26, 0.01,.73,.98];

handles.panel_graphmulti = uipanel(gcf, 'BackgroundColor','k',...
    'Units','normalized','Visible','on',...
    'Position',panelgraph_pos,'Visible','off');

%--------------------------------------------------------------------------
% Turns annotations and cursor visible off
if isfield(handles,'axannot')
    if isobject(handles.axannot)
        if isvalid(handles.axannot)

            axannotvis = zeros(...
                size(handles.axannot,1),size(handles.axannot,2));
            for i = 1:size(handles.axannot,1)
                for j = 1:size(handles.axannot,2)
                    axannotvis(i,j) = get(handles.axannot(i,j),'Visible');
                    set(handles.axannot(i,j),'Visible','off')
                end
            end

        end
    end
end

n_image = size(handles.ax,1);

cursorvis = zeros(3);
for i = 1:3
    cursorvis(1,i) = get(handles.ax{n_image,i}.lx,'Visible');
    set(handles.ax{n_image,i}.lx,'Visible','off')
    
    cursorvis(2,i) = get(handles.ax{n_image,i}.ly,'Visible');
    set(handles.ax{n_image,i}.ly,'Visible','off')
    
    cursorvis(3,i) = get(handles.ax{n_image,i}.txy,'Visible');
    set(handles.ax{n_image,i}.txy,'Visible','off')
    
end

%--------------------------------------------------------------------------
% Get parameters for generating multi slices

v = handles.popup_scrshtax.Value;
nx = round(str2double(handles.edit_mosaiccol.String));
ny = round(str2double(handles.edit_mosaiclin.String));

s1 = round(str2double(handles.edit_mosaicinitslice.String));
sn = round(str2double(handles.edit_mosaiclastslice.String));
s = round(linspace(s1,sn,nx*ny));

px = str2double(handles.edit_coloverlap.String);
py = str2double(handles.edit_linoverlap.String);

w = 1/(abs(px)*(nx-1)+1);
h = 1/(abs(py)*(ny-1)+1);

%--------------------------------------------------------------------------
% Generate image mosaic in the panel_graphmulti
c = 0;
for j = 1:ny % lines
    for i = 1:nx % columns
   
        c = c + 1;
        if px < 0
            x = (nx-i)*w*abs(px);
        else
            x = (i-1)*w*abs(px);
        end

        if py < 0
            y = (j-1)*h*abs(py);
        else
            y = (ny-j)*h*abs(py);
        end

        handles.mosaicax(j,i) = axes('Parent', handles.panel_graphmulti,...
            'Position',[x,y,w,h],'Units','normalized',...
            'Box','off','XTick',[],'YTick',[],'Color','none');

        set(handles.edit_pos(2,4-v),'String',num2str(s(c)))
        editpos_callback(handles.edit_pos(2,4-v),[])
        
        pos = GetLayoutInformation(handles.ax{1,v}.ax);
        rect = pos.PlotBox - [0,0,2,2];
        rect(1:2) = 1;
        

        f = getframe(handles.ax{1,v}.ax,rect);
        im = frame2im(f);
        d = image(im,'Parent',handles.mosaicax(j,i));

        a = (sum(im,3))>0;
        d.AlphaData = a;

        set(handles.mosaicax(j,i),'XLimMode','auto','YLimMode','auto',...
            'XTick',[],'YTick',[],'Color','none',...
            'XColor','none','YColor','none');

        axis image
    end
end

set(handles.panel_graphmulti,'Visible','on');

%--------------------------------------------------------------------------
% Turns annotations and cursor visibility as they were previously 
if isfield(handles,'axannot')
    if isobject(handles.axannot)
        if isvalid(handles.axannot)

            for i = 1:size(handles.axannot,1)
                for j = 1:size(handles.axannot,2)
                    set(handles.axannot(i,j),'Visible',axannotvis(i,j));
                end
            end

        end
    end
end

for i = 1:3
    set(handles.ax{n_image,i}.lx,'Visible',cursorvis(1,i))
    set(handles.ax{n_image,i}.ly,'Visible',cursorvis(2,i))
    set(handles.ax{n_image,i}.txy,'Visible',cursorvis(3,i))
end


guidata(hObject,handles)