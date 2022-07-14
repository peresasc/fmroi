function mask = regiongrowingmask(srcvol, seed, diffratio, grwmode, nvox, premask)
% regiongrowingmask searches for the kvox highest-intensity voxels of the
% srcvol contained in the region defined by premask.
%
% Syntax:
%   mask = regiongrowingmask(srcvol, seed, diffratio, tfMean, grwmeth,...
%                            nvox, premask)
%
% Inputs:
%      srcvol: 3D matrix, usually a data volume from a nifti file.
%        seed: 3D integer vector with the initial position for the growing
%              algorithm.
%   diffratio: Scalar that contains a constant that defines the maximum
%              magnitude difference of the neighborhood with respect to the
%              seed, i.e., neighbor_mag - seed_mag =< diffratio * seed_mag.
%     grwmode: Growing mode - search for most similar neighbor 'diff' or
%              search for the maximum neighbor 'max'.
%        nvox: Integer that defines the maximum number of voxels in mask.
%     premask: Binary 3D matrix with same size as srcvol that defines the
%              region where the region growing will de applied. If premask
%              is not a binary matrix, regiongrowingmask will consider as
%              ROI all non-zero elements.
%
% Output:
%      mask: Binary 3D matrix with the same size as srcvol.
%
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

%==========================================================================
% HEADER
%==========================================================================
if seed(1) < 1 || seed(2) < 1 || seed(3) < 1 ||...
        seed(1) > size(srcvol,1) || seed(2) > size(srcvol,2) ||...
        seed(3) > size(srcvol,3)
    error('Initial position out of bounds, please try again!')
end

if ~exist('diffratio', 'var') || isempty(diffratio)
    diffratio = Inf;
end

if ~exist('grwmode', 'var') || isempty(grwmode)
    grwmode = 'max';
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

srcmaskidx = find(premask);

seedval = double(srcvol(seed(1),seed(2),seed(3)));

neighbors = [seed(1), seed(2), seed(3), seedval];

curnvox = 0;
while size(neighbors, 1)
    switch lower(grwmode)

        %------------------------------------------------------------------
        % Differential mode in relation to the seed
        case 'diff'
            n = 1;
            while n
                qdiff = abs(neighbors(:,4)-seedval);
                [curval,curvox] = min(qdiff);
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
        % Maximum mode   
        case 'max'
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
        case 'min'
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

        otherwise
            error('Selected method not specified. Allowed entry: max, min or diff.')

    end

    x = neighbors(curvox,1);
    y = neighbors(curvox,2);
    z = neighbors(curvox,3);

    curnvox = curnvox+1;
    mask(x,y,z) = true;

    neighbors(curvox,:) = [];
    if curnvox>nvox % test if the maximum number of elements was already reached
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