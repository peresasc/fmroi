function drawingmask
% drawingmask is a tool for generating ROIs from freehand drawings
% layer by layer over planar images. This tool does not have a standalone
% version, so it works only alongside with the fMROI graphical interface.
%
% Settings:
%   Source image: Selected image in the list of loaded images.
%    Working ROI: defines where the drawn ROI will be placed.
%                      'new' - create a new ROI variable and list it in ROI
%                              table.
%                 'roi_name' - place the drawn ROI over the selected ROI 
%                              (listed in ROI Table).
%   Working axis: defines in which planar image the ROI draw will take
%                 place (Axial, Coronal or Sagittal).
%                 
% Drawing method: defines which method will be used to draw the ROI.
%                 'Freehand' - in this method it is necessary to click and
%                               hold the left mouse button while drawing  
%                               the ROI outline.
%                  'Polygon' - in this method the vertices are created
%                              clicking the left mouse button. Double click
%                              to close the polygon.
%  Drawing tools: Tools for creating/editing ROI drawings.
%                  Draw - Enable drawing the ROI in the specified axis.
%                 Clear - Clears the current ROI drawing.
%                   Add - Converts the current draw in a mask and insert it
%                         into the selected ROI. The mask index will be 1
%                         if 'working ROI' is 'new' otherwise it will be 
%                         the highest value of the selected ROI.  
%                   Rem - Fills with zeros the drawn ROI and updates the
%                         selected ROI.