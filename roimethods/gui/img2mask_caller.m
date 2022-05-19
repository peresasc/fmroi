function mask = img2mask_caller(hObject, masktype)
% spheremask_caller is an internal function of fMROI. It calls the 
% spheremask function for creating spherical masks.
% 
% Syntax:
%   mask = spheremask_caller(hObject,srcvol,curpos)
% 
% Inputs:
%    hObject: handle of the figure that contains the fMROI main window.
%   masktype: String containing the keywords 'mask' or 'premask'. It
%             defines if the source image to be masked come from the
%             uitable table_listimg in the panel_control (mask) or from  
%             the popup popup_maskimg in the uitab tab_genroi (premask).
%
% Output: 
%       mask: Binary 3D matrix with the same size as srcvol. 
% 
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com
global st
handles = guidata(hObject);

if ~exist('masktype','var')
    masktype = 'mask';
end

switch masktype    
    case 'mask'
        n = handles.table_selectedcell(1);
    case 'premask'
        n = get(handles.popup_maskimg,'Value');        
end

minthrs = handles.imgprop(n).minthrs;
minthrs = minthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))...
    + st.vols{n}.clim(1);

maxthrs = handles.imgprop(n).maxthrs;
maxthrs = maxthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))...
    + st.vols{n}.clim(1);

srcvol = spm_data_read(st.vols{n});
mask = img2mask(srcvol,minthrs,maxthrs);