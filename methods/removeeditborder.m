function removeeditborder(h,editable)
% removeeditborder removes the edges of the edit text and allow enabling
% or disabling the editable propertie.
%
% Syntax:
%   removeeditborder(h,editable)
%
% Inputs:
%          h: Handle of the edit text to be modified.
%   editable: logical scalar:
%                0 disable the editing propertie.
%                1 enable the editing propertie.
%
% This function uses the findjobj package:
% <a href="https://www.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects">https://www.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects</a>
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

jEdit = findjobj(h);

lineColor = java.awt.Color(1,0,0);  % =red
thickness = 0;  % pixels
roundedCorners = true;
newBorder = javax.swing.border.LineBorder(lineColor,thickness,roundedCorners);

jEdit.Editable = editable;
jEdit.Border = newBorder;
jEdit.repaint;  % redraw the modified control