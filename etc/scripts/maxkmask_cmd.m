function mask = maxkmask_cmd(indata, nvox, varargin)
% function mask = maxkmask_cmd(indata, nvox, premask, property_name, property_value)
%
% Required Arguments:
%
% indata - image volume (3D matrix) or a path to a nifti image.
% nvox - number of voxels (if integer) or porcentage of voxels in the
% premask (if between 0 and 1).
%
% Optional Argumets:
%
% premask - Defines the pre mask type
%   Properties:
%       sphere - Creates a spherical premask ecntered in C with radius r.
%           Value: 4 element vector, the firsts 3 elemtes are the x, y and
%           z are the sphere center coordinates and the 4th element is the
%           radius size in voxels.
%
%       image - Uses an image thresholded between minthrs and maxthrs as
%       a premask.
%           value: 2 elements cell array, the first element is the image
%           volume (3D matrix) or a path to a nifti image. The second
%           element contain a 2 elements vector where the first element is
%           the threshold inferior limit (minthrs) and the second element
%           is the threshold superior limit.
%
%       all - Do not creates a pre mask, and uses all non-zero elements
%       from the vol.
%
% save - Saves the resulting mask in a nifti file.
%   Value: A string vector containing the full path of the image to be
%   saved. Requires template.
%
% template - Defines the image template to save the resulting mask as nifi
% file.
%   Value: A string vector containing the full path of the image to be
%   loaded as template. If the property template is missing, the indata
%   will be used as template (indata must be a path).
%
% PeresASC 07/08/2020

premask_id = find (strcmp(varargin,'premask'));
if premask_id
    premasktype = varargin{premask_id+1};
else
    premasktype = 'all';
end

save_id = find (strcmp(varargin,'save'));
if save_id
    savepath = varargin{save_id+1};
    
    template_id = find (strcmp(varargin,'template'));
    if template_id
        templatepath = varargin{template_id+1};
    elseif ischar(indata)
        templatepath = indata;
    else
        clear savepath
    end
    
end


if ischar(indata)
    V = spm_vol(indata);
    vol = spm_data_read(V);
else
    vol = indata;
end

switch premasktype
    case 'sphere'
        center = varargin{premask_id+2}(1:3);
        radius = varargin{premask_id+2}(4);
        premask = spheremask(vol, center, radius, 'radius');
        
    case 'image'
        if ischar(varargin{premask_id+2}{1})
            V = spm_vol(varargin{premask_id+2}{1});
            prevol = spm_data_read(V);
        else
            prevol = varargin{premask_id+2}{1};
        end
        
        minthrs = varargin{premask_id+2}{2}(1);
        maxthrs = varargin{premask_id+2}{2}(2);
        premask = img2mask(prevol,minthrs,maxthrs);
        
    case 'all'
        premask = vol;
        
    otherwise
        error('Undefined method type: the method should be sphere or image')
        
end


roi_ind = find(premask);
vetroi = vol(roi_ind);
[~, kvet] = maxk(vetroi(:),nvox);
k = roi_ind(kvet);
mask = zeros(size(vol));
mask(k) = 1;

if exist('savepath','var')
    tempV = spm_vol(templatepath);
    tempV.fname = savepath;
    V1 = spm_create_vol(tempV);    
    V1 = spm_write_vol(V1, mask);
end

