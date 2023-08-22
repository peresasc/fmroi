function listener_multioverlap_callback(~,eventdata,hObject)
% listener_minthrs_callback is an internal function of fMROI.
%
% Syntax:
%   listener_minthrs_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_minthrs.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
sv = get(eventdata.AffectedObject,'Value');
        
v = 2*sv-1;
set(handles.edit_multioverlap,'String',v);


if isfield(handles,'multiax')
    if isobject(handles.multiax(1))
        if isvalid(handles.multiax(1))
            
            nx = length(handles.multiax);
            px = str2double(handles.edit_multioverlap.String);
            w = 1/(abs(px)*(nx-1)+1);
            h = 1;

            for i = 1:nx
                if px < 0
                    x = (nx-i)*w*abs(px);
                else
                    x = (i-1)*w*abs(px);
                end

                y = 0;
                set(handles.multiax(i),'Position',[x,y,w,h]);
            end

        end
    end
end
