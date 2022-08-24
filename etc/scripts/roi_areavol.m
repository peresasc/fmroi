function [area,vol,inneredge,outeredge] = roi_areavol(data)


if ischar(data)
    v = spm_vol(data);
    auxdata = spm_data_read(v);
    
    clear data
    data = auxdata;
end

outeredge = zeros(size(data));
inneredge = zeros(size(data));
[x,y,z] = find3d(data);
vol = length(x);
area = 0;
for i = 1:vol
    for j = -1:1
        if x(i)+j>0 && x(i)+j<=size(data,1) % Test if the voxel is in the x limits
            if data(x(i)+j,y(i),z(i)) == 0
                area = area+1;
                outeredge(x(i)+j,y(i),z(i)) = 1;
                inneredge(x(i),y(i),z(i)) = 1;
            end
        end

        if y(i)+j>0 && y(i)+j<=size(data,2) % Test if the voxel is in the y limits
            if data(x(i),y(i)+j,z(i)) == 0
                area = area+1;
                outeredge(x(i),y(i)+j,z(i)) = 1;
                inneredge(x(i),y(i),z(i)) = 1;
            end
        end

        if z(i)+j>0 && z(i)+j<=size(data,3) % Test if the voxel is in the z limits
            if data(x(i),y(i),z(i)+j) == 0
                area = area+1;
                outeredge(x(i),y(i),z(i)+j) = 1;
                inneredge(x(i),y(i),z(i)) = 1;
            end
        end
    end
end