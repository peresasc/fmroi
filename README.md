# fMROI

_Software dedicated to create ROIs in fMRI data_

[![N|Solid](https://proactionlab.fpce.uc.pt/images/ProactionLab_AboutLogo.png)](https://proactionlab.fpce.uc.pt/)

## Description

FMROI is a technical software specialized for working with fMRI data. It would be beneficial for neuroimaging communities and laboratories. We assume that the clients of this software have sufficient knowledge of fMRI data analysis and they are familiar with the related concepts. Before using and running the project, ensure that you have installed the pre-requirement packages. 

## Getting Started

### Dependencies

* MATLAB
* SPM 

### Installing

You can easily download the source file of the project or clone the project from the GitHub link as follow and then run it via Matlab. 

For this purpose, go to the local directory where you want to locate the project and run the following command:
```sh
git clone https://github.com/proactionlab/fmroi.git
```


### Tutorials

- To load an image, the users have three alternatives: 
1. by clicking on *File>Open Menu*, to open a nifti file (functional, structural, DTI, etc.);
2. by clicking on the menu *File>Load ROI* to open a binary nifti file and automatically use it as ROI;
3. clicking on *File>Load Template* to open one of the templates installed in fMROI. 

After loading the image, users can create and manipulate ROls in the tabs at the bottom of the control panel. 

- To create an ROI, the user must click on the *Gen ROI* tab, select the method from the popup menu, adjust the parameters and when ready, click on the *Gen ROI* button. 

After this procedure the generated ROI will appear in the *ROI Table* tab, as well as an image will appear in the list of loaded images (*roi_under-construction.nii*). 

- To save the ROls, the user must select the *Bin Mask* checkbox to save each ROI as an independent mask, or *Atlas+LUT* to save all the ROls in the same image and click on the Save button at the bottom of the *ROI Table* tab. 

## Development

Want to contribute? Great! Send an email to _m72.morteza(@)gmail.com_.

## License

GNU GENERAL PUBLIC LICENSE
**Free Software**

[//]: # (These are reference links used in the body of this note.)
   
   [PROACTION]: <https://proactionlab.fpce.uc.pt/>

