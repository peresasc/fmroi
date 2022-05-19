# fMROI
Software dedicated to create ROIs in fMRI data

-------
default argument names used by roi algoritms:

hObject - main figure handle.
srcvol - source volume, a 3D matrix in RAS with the image information.
curpos - cursor current position, it is a 3D vector with the cursor position in RAS.
minthrs - handles.slider_minthrs: minimum threshold, srcvol values below the minthrs receive zero; 
maxthrs - handles.slider_maxthrs: maximum threshold, srcvol values higher than maxthrs receive zero;
