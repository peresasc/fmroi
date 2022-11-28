function change_slicesview_callback(h,~)

    
handles = guidata(h);

slice_idx = handles.slices;
v = handles.view;
path = '/home/proactionlab/Desktop/Fer/Brainfer.nii';

switch h.Text
    case 'Sagital'
        v = 1;
    case 'Coronal'
        v = 2;
    case 'Axial'
        v = 3;
end
        



handles.view = v;
guidata(h,handles);
menutools_displayslices(h.Parent.Parent.Parent,path,slice_idx,v);



a = 1;
