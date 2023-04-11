function axtoolbar_slicegrid_callback(hObject, event)

handles = guidata(hObject);

origpos = [0.26, 0.01, 0.365, 0.49;...
    0.26, 0.5, 0.365, 0.49;...
    0.625, 0.5, 0.365, 0.49;...
    0.625, 0.01, 0.365, 0.49;...
    0.26, 0.01, 0.73, 0.98];

% uistack(handles.panel_graph(3),"up",4);
% uistack is unstable so we made a workaround which is to hide
% the other axes behind the control panel.
panelpos = event.Axes.Parent.Position;
set(handles.panel_graph(1),'Position',[.02,.02,.1,.1],'Visible','off')
set(handles.panel_graph(2),'Position',[.02,.02,.1,.1],'Visible','off')
set(handles.panel_graph(3),'Position',[.02,.02,.1,.1],'Visible','off')
set(handles.panel_graph(4),'Position',[.02,.02,.1,.1],'Visible','off')

if panelpos(4) ~= origpos(1,4)
    hObject.Icon = 'gridoff.png';
    for i = 1:4
        set(handles.panel_graph(i),'Position',origpos(i,:),'Visible','on')
    end
else
    hObject.Icon = 'gridon.png';
    switch event.Axes.Tag(1:3)
        case 'tra'
        set(handles.panel_graph(1),'Position',origpos(5,:),'Visible','on')
        case 'cor'
        set(handles.panel_graph(2),'Position',origpos(5,:),'Visible','on')
        case 'sag'
        set(handles.panel_graph(3),'Position',origpos(5,:),'Visible','on')
        case 'ren'
        set(handles.panel_graph(4),'Position',origpos(5,:),'Visible','on')
    end
end


guidata(hObject,handles);