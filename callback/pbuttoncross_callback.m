function pbuttoncross_callback(hObject, ~)
% pbuttoncross_callback is an internal function of fMROI.
%
% Syntax:
%   pbuttoncross_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

handles = guidata(hObject);

for i = 1:3
    set(handles.ax{1,i}.lx,'Visible','off')
    set(handles.ax{1,i}.ly,'Visible','off')
    set(handles.ax{1,i}.txy,'Visible','off')
end

switch handles.pbuttoncross.action
    case 1
        handles.pbuttoncross.action = 2;
        set(handles.pbuttoncross.obj,'String','')
        for i = 1:3
            set(handles.ax{1,i}.txy,'Visible','on')
        end
    case 2
        set(handles.pbuttoncross.obj,'String','_|_')
        handles.pbuttoncross.action = 3;
    case 3
        handles.pbuttoncross.action = 1;
        set(handles.pbuttoncross.obj,'String','+')
        for i = 1:3
            set(handles.ax{1,i}.lx,'Visible','on')
            set(handles.ax{1,i}.ly,'Visible','on')
        end
end

guidata(hObject, handles);
