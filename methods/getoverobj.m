function h = getoverobj(varargin)
% getoverobj get handle of object that the pointer is over.
% Modified from overobj2 function at:
% http://undocumentedmatlab.com/blog/undocumented-mouse-pointer-functions
%
% Original help:
%--------------------------------------------------------------------------
% OVEROBJ2 Get handle of object that the pointer is over.
%   H = OVEROBJ2 searches all objects in the PointerWindow
%   looking for one that is under the pointer. Returns first
%   object handle it finds under the pointer, or empty matrix.
%
%   H = OVEROBJ2(FINDOBJ_PROPS) searches all objects which are
%   descendants of the figure beneath the pointer and that are
%   returned by FINDOBJ with the specified arguments.
%
%   Example:
%       h = overobj2('type','axes');
%       h = overobj2('flat','visible','on');
%
%   See also OVEROBJ, FINDOBJ
% Ensure root units are pixels
%--------------------------------------------------------------------------
%
% Last update: Andre Peres, 16/08/2019, peres.asc@gmail.com
 
% Ensure root units are pixels
oldUnits = get(0,'units');
set(0,'units','pixels');
 
% Get the figure beneath the mouse pointer & mouse pointer pos
try
   fig = get(0,'PointerWindow');  % HG1: R2014a or older
catch
   fig = matlab.ui.internal.getPointerWindow;  % HG2: R2014b or newer
end
p = get(0,'PointerLocation');
set(0,'units',oldUnits);
 
% Look for quick exit (if mouse pointer is not over any figure)
if fig==0,  h=[]; return;  end
 
% Compute figure offset of mouse pointer in pixels
figPos = getpixelposition(fig);
x = (p(1)-figPos(1));
y = (p(2)-figPos(2));
 
% Loop over all figure descendants
c = findobj(get(fig,'Children'),varargin{:});

try
    hp = get(c(1),'Parent');
    
    while hp~=fig
        parent_pos = getpixelposition(hp);
        x = (x-parent_pos(1));
        y = (y-parent_pos(2));
        hp = get(hp,'Parent');
    end
end

for h = c'
   % If descendant contains the mouse pointer position, exit
   r = getpixelposition(h);  % Note: cache this for improved performance
   if (x>r(1)) && (x<r(1)+r(3)) && (y>r(2)) && (y<r(2)+r(4))
      return
   end
end
h = [];