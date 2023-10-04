%%

srcvol ='/home/andre/github/templates/Neurosynth/default_mode_association-test_z_FDR_0.01.nii.gz';


outpath ='/home/andre/github/test1/spheremask/testsphere.andre';
curpos = [46,55,46];
nvoxels = 5;
mode = 'radius';
mask_sph = spheremask(srcvol,curpos,nvoxels,mode,outpath);


outpath ='/home/andre/github/test1/cubicmask/testcubic.andre';
curpos = [46,55,46];
nvoxels = 5;
mode = 'edge';
mask_cub = cubicmask(srcvol,curpos,nvoxels,mode,outpath);


outpath ='/home/andre/github/test1/img2mask/testimg.andre';
minthrs = 7;
maxthrs = 50;
mask_img = img2mask(srcvol,minthrs,maxthrs,outpath);


outpath ='/home/andre/github/test1/maxkmask/testmaxk.andre';
premask = srcvol;
kvox = 100;
mask_max = maxkmask(srcvol,premask,kvox,outpath);

%%
outpath ='/home/andre/github/test1/regiongrowing/testgrw.andre';
seed = [46,36,46];
diffratio = Inf;
grwmode = 'ascending';
nvox = 100;
premask = srcvol;
mask_grw = regiongrowingmask(srcvol,seed,diffratio,grwmode,nvox,premask,outpath);
%%

outpath ='/home/andre/github/test1/cluster/testcluster.andre';
minthrs = 7;
maxthrs = 50;
mincltsz = 5;
mask = contiguousclustering(srcvol,minthrs,maxthrs,mincltsz,outpath);