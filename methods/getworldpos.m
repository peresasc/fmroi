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
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 30/10/2026, peres.asc@gmail.com
global st

centre = [];

if ~exist('h','var') || isempty(h)
    h = getoverobj('type', 'axes');
    if isempty(h)
        return;
    end
end

if ~ishandle(h) || ~strcmp(get(h, 'Type'), 'axes')
    return;
end

tag = get(h, 'Tag');
if contains(tag, 'transversal')
    tag = 'transversal';
elseif contains(tag, 'coronal')
    tag = 'coronal';
elseif contains(tag, 'sagital')
    tag = 'sagital';
else
    return;
end

cp = get(h, 'CurrentPoint');
if isempty(cp)
    return;
end
cp = cp(1, 1:2);

xlim = get(h, 'XLim');
ylim = get(h, 'YLim');
if cp(1) < xlim(1) || cp(1) > xlim(2) || cp(2) < ylim(1) || cp(2) > ylim(2)
    return;
end

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

if ~isempty(cent)
    centre = st.Space*[cent',1]';
    centre = centre(1:3)';
end