function outrsh = spacetransform(rshaff,srcaff,rshimg,srcimg)

% outrsh = spacetransform(rshaff,srcaff,rshimg,srcimg)
% 
% spacetransform transforms a volumetric image or a set of 3D positions
% from a space defined for affine matrix rshaff to a new space define for
% the affine matrix srcaff.
%
% Inputs:
%
% rshaff: 4x4 Affine matrix that describes the positions of rshimg.
% srcaff: 4x4 Affine matrix that describes the positions of srcimg, where one
%         wish to represent the position of rshimg.
% rshimg: nxmxp volume image or a nx3 matrix containing the positions which
%         wants to transform.
% srcimg: XxYxZ volume image deffined by the affine matrix srcaff. The
% output volume has the same dimensons.

if length(size(rshimg)) == 3
    
    [x,y,z] = meshgrid(1:size(srcimg,1),1:size(srcimg,2),1:size(srcimg,3));
    pos = [x(:),y(:),z(:)];
    
    cprsh = afftransform (pos,srcaff,rshaff);    
    rshsub = round(cprsh);  
    srcsub = round(pos);
    
    for i = 1:3 % remove the positions out of the bounds
        k = rshsub(:,i)<1|rshsub(:,i)>size(rshimg,i); 
        rshsub(k,:)=[];
        srcsub(k,:)=[];
    end
    
    rshidx = sub2ind(size(rshimg), rshsub(:,1), rshsub(:,2), rshsub(:,3));
    srcidx = sub2ind(size(srcimg), srcsub(:,1), srcsub(:,2), srcsub(:,3));
    
    rimg = zeros(size(srcimg));
    rimg(srcidx) = rshimg(rshidx);
    outrsh = rimg;
    
else
    outrsh = afftransform (rshimg,rshaff,srcaff);
end


function cprsh = afftransform (pos,aff1,aff2)
% pos - positions, 3xn matriz where the lines are the samples and columns
% are the dimensions. Example:
%     [x1 y1 z1
%      x2 y2 z2
%      x3 y3 z3]
% aff1 - affine matrix of the pos.
% aff2 - affine matrix that want transform to.

cpwldm = aff1*[pos,ones(size(pos,1),1)]';
cprsh = round(aff2\cpwldm);
cprsh = cprsh(1:3,:)';
