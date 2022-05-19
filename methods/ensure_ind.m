function cp = ensure_ind(volsize,cp_in)
% ensure_ind checks whether each of the rows of the mx3 cp_in matrix are
% coordinates contained in the subspace defined by the vector volsize and 
% removes thouse lines that are out of the range.
%
% Syntax:
%   cp = ensure_ind(volsize,cp_in)
%
% Inputs:
%   volsize: 3D vector that defines the subspace dimensions x y and z.
%     cp_in: mx3 matrix where the lines are x, y and z coordinates.
%
% Outputs:
%        cp: nx3 matrix, subset of cp_in which the coordinates are 
%            contained in the subspace defined by volsize vector.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

count = 0;
for i = 1:size(cp_in,1)
   
   if cp_in(i,1)>volsize(1) || cp_in(i,2)>volsize(2) || cp_in(i,3)>volsize(3)
       count = count+1;
       outofrange(count) = i;
   end
end

cp = cp_in;
if exist('outofrange','var')
    if ~isempty(outofrange)
        cp(outofrange,:) = [];
    end
end