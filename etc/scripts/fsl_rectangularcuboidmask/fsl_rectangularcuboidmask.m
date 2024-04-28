function mask = fsl_rectangularcuboidmask(hObject,curpos,srcvol,xs,ys,zs)

handles = guidata(hObject);
outpath = fullfile(handles.tmpdir,'fslroi.nii.gz');
x = curpos(1)-1; % subtract 1 because fsl first voxel is [0,0,0]
y = curpos(2)-1;
z = curpos(3)-1;

cmd = 'fslmaths %s -mul 0 -add 1 -roi %d %d %d %d %d %d 0 1 %s -odt float';

setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);
system(sprintf(cmd,srcvol,x,xs,y,ys,z,zs,outpath));

v = spm_vol(outpath);
mask = spm_data_read(v);
