function mask = regiongrowingmask(srcvol,seed,diffratio,grwmode,nvox,premask,varargin)
% regiongrowingmask is a region growing algorithm that groups neighboring
% voxels from a seed iteratively according to a rule. The regiongrowingmask
% has three rules for growing (grwmode), ascending, descending and 
% similarity to the seed, and three other rules for stopping growth, 
% maximum number of voxels (nvox), region set by a mask (premask), and 
% maximum difference in values between the seed and its neighbors
% (diffratio).
%
% Syntax:
%   mask = regiongrowingmask(srcvol, seed, diffratio, tfMean, grwmeth,...
%                            nvox, premask)
%
% Inputs:
%      srcvol: srcvol: 3D matrix or NIfTI file path used as the ROI
%              template.
%        seed: 3D integer vector with the initial position for the growing
%              algorithm.
%   diffratio: Scalar that defines the maximum magnitude difference of the
%              neighborhood with respect to the seed, i.e.:
%              |neighbor_mag - seed_mag| =< |diffratio|.
%     grwmode: String - Defines de growing mode:
%                 'ascending' - searches for the neighbor with the maximum
%                               value every each iteration.
%                'descending' - searches for the neighbor with the minimum
%                               value every each iteration.
%                'similarity' - searches for the neighbor with the most 
%                               similar value to the seed.
%        nvox: Integer that defines the maximum number of voxels in ROI.
%     premask: Binary 3D matrix or NIfTI file path with same size as srcvol
%              that defines the region where the region growing will be
%              applied. If premask is not a binary matrix,
%              regiongrowingmask will binarize it considering TRUE all
%              non-zero elements.
%    varargin: Output file path for ROIs in NIfTI format. If a different
%              extension is entered, it will be automatically set to .nii.
%              Set this parameter only for NIfTI file saving.
%
% Output:
%      mask: Binary 3D matrix with the same size as srcvol.
%
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 04/10/2023, peres.asc@gmail.com

%==========================================================================
% HEADER
%==========================================================================
if ischar(srcvol)
    srcpath = srcvol;
    v = spm_vol(srcvol);
    auxdata = spm_data_read(v);
    
    clear srcvol
    srcvol = auxdata;
end

if ischar(premask)
    v = spm_vol(premask);
    auxpremask = spm_data_read(v);
    
    clear premask
    premask = auxpremask;
end

if seed(1) < 1 || seed(2) < 1 || seed(3) < 1 ||...
        seed(1) > size(srcvol,1) || seed(2) > size(srcvol,2) ||...
        seed(3) > size(srcvol,3)
    error('Initial position out of bounds, please try again!')
end

if ~exist('diffratio', 'var') || isempty(diffratio)
    diffratio = Inf;
end

if ~exist('grwmode', 'var') || isempty(grwmode)
    grwmode = 'ascending';
end

if ~exist('nvox', 'var') || isempty(nvox)
    nvox = Inf;
end

if ~exist('premask', 'var') || isempty(premask)
    premask = ones(size(srcvol));
end

%==========================================================================
% MAIN
%==========================================================================

mask = false(size(srcvol));
neighmask = false(size(srcvol));
neighmask(seed(1),seed(2),seed(3)) = true;

srcmaskidx = find(premask);

seedval = double(srcvol(seed(1),seed(2),seed(3)));

neighbors = [seed(1),seed(2),seed(3),seedval];

curnvox = 0;
while size(neighbors, 1)
    switch lower(grwmode)

        %------------------------------------------------------------------
        % Maximum mode   
        case 'ascending'
            n = 1;
            while n
                [curval,curvox] = max(neighbors(:,4));
                if abs(curval-seedval) > abs(diffratio) % abs(seedval*diffratio)
                    neighbors(curvox,:) = [];
                else
                    n = 0;
                end
            end

            if ~size(neighbors, 1)
                break
            end

        %------------------------------------------------------------------
        % Minimum mode
        case 'descending'
            n = 1;
            while n
                [curval,curvox] = min(neighbors(:,4));
                if abs(curval-seedval) > abs(diffratio) % abs(seedval*diffratio)
                    neighbors(curvox,:) = [];
                else
                    n = 0;
                end
            end

            if ~size(neighbors, 1)
                break
            end

        %------------------------------------------------------------------
        % Differential mode in relation to the seed
        case 'similarity'
            n = 1;
            while n
                qdiff = abs(neighbors(:,4)-seedval);
                [~,curvox] = min(qdiff);
                curval = neighbors(curvox,4);
                if abs(curval-seedval) > abs(diffratio) % abs(seedval*diffratio)
                    neighbors(curvox,:) = [];
                else
                    n = 0;
                end
            end

            if ~size(neighbors, 1)
                break
            end

        otherwise
            error('Selected method not specified. Allowed entry: max, min or diff.')

    end

    x = neighbors(curvox,1);
    y = neighbors(curvox,2);
    z = neighbors(curvox,3);

    curnvox = curnvox+1;
    mask(x,y,z) = true;

    neighbors(curvox,:) = [];
    if curnvox>=nvox % test if the maximum number of elements was already reached
        break
    end

    %----------------------------------------------------------------------
    % Search for new neighbors
    for i = -1:1
        for j = -1:1
            for k = -1:1
                if ismember(sub2ind(size(srcvol),x+i,y+j,z+k),srcmaskidx) &&... % Test if curpos is within the mask bounds
                        any([i, j, k]) &&... % avoid picking the curvox
                        ~neighmask(x+i, y+j, z+k) % avoid picking pixel positions already set

                    neighmask(x+i, y+j, z+k) = true;
                    neighbors(end+1,:) = [x+i, y+j, z+k, srcvol(x+i, y+j, z+k)];
                end
            end
        end
    end

end

%--------------------------------------------------------------------------
% Save mask to a nifti file
if ~isempty(varargin)
    [pn,fn,~] = fileparts(varargin{1});
    if ~isempty(pn) && ~exist(pn,'dir')
        mkdir(pn);
    end

    outpath = fullfile(pn,[fn,'.nii']);
    mask = uint16(mask);
    mat2nii(mask,srcpath,outpath)
end