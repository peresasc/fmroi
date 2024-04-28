function mask = fsl_rectangularcuboidmask(curpos,srcvol,xs,ys,zs)

x = curpos(1);
y = curpos(2);
z = curpos(3);
% srcvol = '/home/andre/tmp/fsl_test/T1.nii.gz';

cmd = 'fslmaths %s -mul 0 -add 1 -roi %d %d %d %d %d %d 0 1 /home/andre/tmp/fsl_test/roi2.nii.gz -odt float';

setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);
system(sprintf(cmd,srcvol,x,xs,y,ys,z,zs));

v = spm_vol('/home/andre/tmp/fsl_test/roi2.nii.gz');
mask = spm_data_read(v);
