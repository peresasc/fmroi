function mask = simplecylidermask(srcvol,curpos,radius,height)

[len_x,len_y,~] = size(srcvol);
mask = zeros(size(srcvol));

x = (1:len_x)';
y = 1:len_y;
c = ((x-curpos(1)).^2 + (y-curpos(2)).^2 <= radius^2);
cyl  = repmat(c,1,1,height);

mask(:,:,curpos(3):curpos(3)+height-1) = cyl;