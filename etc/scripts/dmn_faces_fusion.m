%%
dmnpath = '/home/andre/github/tmp/neurosynth_paperfmroi/default mode_association-test_z_FDR_0.01.nii.gz';
facespath = '/home/andre/github/tmp/neurosynth_paperfmroi/faces_association-test_z_FDR_0.01.nii.gz';
dmn_faces_path = fullfile('/home/andre/github/tmp/neurosynth_paperfmroi/dmn_faces_association.nii');

vdmn = spm_vol(dmnpath);
dmndata = spm_data_read(vdmn);
dmndata(dmndata<16) = 0;

vfaces = spm_vol(facespath);
facesdata = spm_data_read(vfaces);
facesdata(facesdata<16) = 0;

mdn_faces = dmndata - facesdata;

vdmn.fname = dmn_faces_path;
outvol = spm_create_vol(vdmn);
outvol = spm_write_vol(outvol,mdn_faces);