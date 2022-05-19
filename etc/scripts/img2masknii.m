function img2masknii(indata,outdata,minthrs,maxthrs)
% function mask = img2mask(vol,minthrs,maxthrs)


if ischar(indata)
    v = spm_vol(indata);
    auxdata = spm_data_read(v);
    
    clear data
    indata = auxdata;
end

if minthrs <= maxthrs
    z = indata > minthrs & indata <= maxthrs; % the pixels should be bigger than 
else                                    % minthrs and equal or lower than maxthrs
    z = indata >= minthrs | indata <= maxthrs;
end

mask = zeros(size(indata));
mask(z) = 1;

v.fname = outdata;
vmask = spm_create_vol(v);
spm_write_vol(vmask, mask);
