function update_coordinates(hObject, varargin)
% update_coordinates is an internal function of fMROI.
%
% Syntax:
%   update_coordinates(hObject, varargin)
%
% Inputs:
%    hObject: handle of the figure that contains the fMROI main window.
%   varargin: handle of the axis that contains one of the three planar
%             images (axial, coronal and sagittal).
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
n = handles.table_selectedcell(1);

if nargin == 1 || handles.mousehold
    
    if nargin == 1
        centre = getworldpos;
    else
        centre = getworldpos(varargin{1});
    end
    st.centre = centre(1:3);
    
    cpima = st.vols{n}.mat\[centre';1];
    cpima = round(cpima(1:3))';
    
    cpall = [centre; cpima];
    for i = 1:2
        for j = 1:3
            set(handles.edit_pos(i,j),'String',num2str(cpall(i,j)))
        end
    end
    set(handles.text_pos(1),'String',num2str(round(centre)))
    set(handles.text_pos(2),'String',num2str(cpima))
    
    voxelvalue = cell(n_image,1);
    for k = 1:n_image
        cp = st.vols{k}.mat\[centre';1];
        cp = round(cp(1:3))';
        
        s = size(st.vols{k}.private.dat);
        if sum((cp<1)+(cp>s))
            voxelvalue{k} = NaN;
        else
            voxelvalue{k} = st.vols{k}.private.dat(cp(1),cp(2),cp(3));
        end
    end
    
    tdata = get(handles.table_listimg,'Data');
    tdata(:,2) = voxelvalue;
    set(handles.table_listimg,'Data',tdata);
    
else
    
    centre = getworldpos(varargin{1});
    cpima = st.vols{n}.mat\[centre';1];
    cpima = round(cpima(1:3))';
    
    set(handles.text_pos(1),'String',num2str(round(centre)))
    set(handles.text_pos(2),'String',num2str(cpima))
end
