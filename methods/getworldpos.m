function centre = getworldpos(h)
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

centre = [];
cent   = [];

if ~exist('h','var')
    cp = get(gca,'CurrentPoint');
    tag = get(gca,'Tag');
elseif isempty(h)
    cp = get(gca,'CurrentPoint');
    tag = get(gca,'Tag');
else
    cp = get(h,'CurrentPoint');
    tag = get(h,'Tag');
end
    
tag = tag(1:end-2);

if ~isempty(cp)
    cp   = cp(1,1:2);
    cent = st.Space\[st.centre,1]';
    cent(end) = [];
    switch tag
        case 'transversal'
            cent([1 2])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,2)-1];
        case 'coronal'
            cent([1 3])=[cp(1)+st.bb(1,1)-1 cp(2)+st.bb(1,3)-1];
        case 'sagital'
            if st.mode ==0
                cent([3 2])=[cp(1)+st.bb(1,3)-1 cp(2)+st.bb(1,2)-1];
            else
                cent([2 3])=[st.bb(2,2)+1-cp(1) cp(2)+st.bb(1,3)-1];
            end
    end    
end

if ~isempty(cent)
    centre = st.Space*[cent',1]';
    centre = centre(1:3)';
end