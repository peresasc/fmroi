function multislice(hObject,~)

handles = guidata(hObject);


panelgraph_pos = [0.26, 0.01,.73,.98];

handles.panel_graphmulti = uipanel(gcf, 'BackgroundColor','k',...
        'Units','normalized','Visible','on',...
        'Position',panelgraph_pos,'Visible','off');

% panel_graphmulti.Units = "pixels";
% p = panel_graphmulti.Position;
% 
% sr = p(3)/p(4);
% 
% ir = size(im,1)/size(im,2);

n = 5;
c = 0;
s = round(linspace(20,70,n));
for i = n:-1:1
    c = c + 1;
    handles.multiax(c) = axes('Parent', handles.panel_graphmulti,...
        'Position',[1-(i/n),0,(1/n),1],'Units','normalized',...
        'Box','off','XTick',[],'YTick',[],'Color','none');

    set(handles.edit_pos(2,3),'String',num2str(s(c)))
    editpos_callback(handles.edit_pos(2,3),[])

    f = getframe(handles.ax{1,1}.ax);
    im = frame2im(f);
    d = image(im,'Parent',handles.multiax(c));

    set(handles.multiax(c),'XLimMode','auto','YLimMode','auto',...
            'XTick',[],'YTick',[],'Color','none','XColor','none','YColor','none');

    
    axis image
end

set(handles.panel_graphmulti,'Visible','on');

guidata(hObject,handles)

% delete(panel_graphmulti)
