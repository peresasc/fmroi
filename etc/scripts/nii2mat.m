function data = nii2mat (path)

V = spm_vol(path);
data = spm_data_read(V);
