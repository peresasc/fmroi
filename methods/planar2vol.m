function volpos = planar2vol(selimg,planarpos,tag,refpos)
% getworldpos is an internal function of fMROI.
%
% Syntax:
%   centre = getworldpos(h)
%
% Inputs:
%        h: handle of the current axes.
%
% Outputs:
%   centre: 1x3 current position vector in the scanner coordinate
%           system in milimiters.
%
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com
global st

volpos = zeros(size(planarpos,1),3);
for i = 1:size(planarpos,1)
    cp = planarpos(i,1:2);
    cent = st.Space\[refpos,1]';
    cent(end) = [];
    switch tag
        case 1 % 'transversal'
            cent([1 2]) = [cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,2)-1];
        case 2 % 'coronal'
            cent([1 3]) = [cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,3)-1];
        case 3 % 'sagital'
            if st.mode ==0
                cent([3 2]) = [cp(1)+st.bb(1,3)-1 cp(2)+st.bb(1,2)-1];
            else
                cent([2 3]) = [st.bb(2,2)+1-cp(1) cp(2)+st.bb(1,3)-1];
            end
    end    

    centre = st.Space*[cent',1]';
    cpima = st.vols{selimg}.mat\centre;
    volpos(i,:) = round(cpima(1:3))';
end