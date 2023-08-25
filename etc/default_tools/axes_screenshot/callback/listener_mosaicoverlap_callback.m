function listener_mosaicoverlap_callback(~,eventdata,hObject)
% listener_mosaicoverlap_callback is an internal function of fMROI.
%
% Syntax:
%   listener_mosaicoverlap_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_minthrs.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 23/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
sv = get(eventdata.AffectedObject,'Value');

v = 2*sv-1;

switch hObject.Tag
    case 'slider_mosaiccol'
        set(handles.edit_coloverlap,'String',v);

    case 'slider_mosaiclin'
        set(handles.edit_linoverlap,'String',v);
end


if isfield(handles,'mosaicax')
    if isobject(handles.mosaicax(1,1))
        if isvalid(handles.mosaicax(1,1))

            nx = size(handles.mosaicax,2);
            ny = size(handles.mosaicax,1);

            px = str2double(handles.edit_coloverlap.String);
            py = str2double(handles.edit_linoverlap.String);

            w = 1/(abs(px)*(nx-1)+1);
            h = 1/(abs(py)*(ny-1)+1);

            for j = 1:ny % lines
                for i = 1:nx % columns
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

                    set(handles.mosaicax(j,i),'Position',[x,y,w,h]);
                end
            end

        end
    end
end

guidata(hObject,handles)
