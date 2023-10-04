function mat2nii(data,srcpath,outpath)

vsrc = spm_vol(srcpath);
vsrc.fname = outpath;
V = spm_create_vol(vsrc);
V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
V = spm_write_vol(V,data);