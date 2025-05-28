Extra Tools
============
The extra tools offer a range of additional functions that, while not crucial to the core functionality of fMROI, can be highly beneficial for various tasks. These tools can be found in the "Tools" menu. By default, fMROI 1.0.x includes a screenshot assistant that enables automated capture of multiple slices and the creation of image mosaics. Additionally, fMROI features an import assistant in the "Config" menu to simplify the integration of new tools. The files for these extra tools are stored in the "tools" folder within the fMROI root directory.

Applymask
----------

Applymask (or runapplymask for command line use) function applies masks to a set fmri images, extracting time-series data and statistical measures from these masked regions, and saving the results to a specified output directory. Optional preprocessing can also be applied to the time series data prior to extraction.

- **Syntax:**
    - *runapplymask(srcpath,maskpath,outdir,opts,hObject)*

- **Inputs:**
    - **srcpath:** String containg the paths to the source images separeted by semicolons, or a path to a text file (.txt, .csv, or .tsv) containing the images paths in a line (separated by tabs or semicolons) or in a column (1D array).
    - **maskpath:** String containg the paths to the mask images separeted by semicolons, or a path to a text file (.txt, .csv, or .tsv) containing the maskpaths paths separated by tabs orsemicolons. The number of mask paths must exactly match the number of source images or there can be only one mask. Each mask in the list is applied to the corresponding source image in the same order (i.e., first mask to first image, second mask to second image, and so on). If the maskpath points to a text file, each column represents a different mask type and will be processed separately. Each column can have as many lines as there are source images or only one mask to be applied to all images.
    - **outdir:** Path to the output directory (string).
   
    - **opts:** Structure with optional settings including preprocessing steps and output options:
        - **opts.saveimg**: (default: 0) Logical flag indicating if masked images should be saved (1 = save, 0 = do not save).
        - **opts.savestats**: (default: 1) Logical flag indicating if statistics should be saved. The saved statistics include mean, median, standard deviation, maximum value, and minimum value for each subject and ROI.
        - **opts.savets**: (default: 1) Logical flag indicating if time series data should be saved.
        - **opts.groupts**: (default: 0) Controls how time series data are saved:
            - If set to 1: time series are grouped and saved per source image (one file per subject).
            - If set to 0: time series are saved separately for each mask (one file per mask).
        
        - **opts.filter.tr**: Repetition time (TR) in seconds. Used to compute the sampling frequency for filtering.
        - **opts.filter.highpass**: High-pass filter cutoff frequency in Hz. Can be a numeric value or the string `'none'`. If numeric, a Butterworth filter is applied.
        - **opts.filter.lowpass**: Low-pass filter cutoff frequency in Hz. Can be a numeric value or the string `'none'`. If numeric, a Butterworth filter is applied.
        - **opts.filter.order**: (Optional, default = 1) Order of the Butterworth filter. Applies to high-pass, low-pass, or band-pass designs.
        
        - **opts.regout.conf**: Table, matrix, or cell array of confound files (numeric or table) to be regressed out via GLM. If multiple subjects are processed, this must be a cell array with one entry per subject.
        - **opts.regout.selconf**: Vector of column indices to select specific confounds from `conf`. Can be empty to include all columns.
        - **opts.regout.demean**: (default: false) Logical flag indicating whether to include a constant (intercept) regressor for mean removal during regression.
        
        - **opts.smooth.fwhm**: Full width at half maximum (FWHM) of the spatial Gaussian kernel in millimeters (scalar).
        
        - **opts.zscore**: Logical flag. If true, the time series of each voxel is z-scored (zero mean, unit standard deviation) after all other preprocessing steps.

    - **hObject:** (Optional - default: NaN) Handle to the graphical user interface object. Not provided for command line usage.

 - **Outputs:** runapplymask saves to the output directory the following data:
    - Masked images (if opts.saveimg is set to 1).
    - Timeseries.mat file containing the source paths, mask paths, and time series data (if opts.savets is set to 1).
    - Median.csv, Mean.csv, Std.csv, Max.csv, Min.csv files containing statistics for each mask applied to each source image (if opts.savestats is set to 1).

*This function requires SPM 12 to be installed.*

Connectome
-----------
 Connectome (or runconnectome for command line use) computes Pearson correlation coefficients, p-values, and Fisher transformation connectomes from input time-series data and saves the results in specified output directories. Optionally, it can save the results as feature matrices for machine-learning use.


- **Inputs:**
    - **tspath:** Path(s) to the time-series data file(s). Supported formats are .mat, .txt, .csv, and .tsv. For .mat files, the data can be a table, cell array, or numeric array:
        - If a Matlab table, it must have a variable named as "timeseries" from where the time-series are extracted and stored in a cell array. Time-series within each cell is processed separately, resulting in as many connectomes as the number of cells. It is possible to obtain this table directly from the applymask algorithm (fmroi/tools).
        - If a cell array, each time-series within each cell is processed separately, resulting in as many connectomes as the number of cells.
        - If a numeric array (matrix) or any other file type, a single connectome is generated for all the time-series, treating them as from the same subject.
    - **outdir:** Directory where the output files will be saved.
    - **roinamespath:** (Optional) Path to the file containing ROI names. Supported formats are .mat, .txt, .csv, and .tsv. The file must have the same length as the number of time-series. Each ROI name in roinamespath corresponds to the ROI from which each time-series was extracted.
                 If not provided, generic names will be assigned.
    - **opts:** Structure with optional settings including preprocessing steps and output options:
        - **opts.rsave**: (default: 1) Save Pearson correlation connectome (logical).
        - **opts.psave**: (default: 1) Save p-values connectome (logical).
        - **opts.zsave**: (default: 1) Save Fisher transformation connectome (logical).
        - **opts.ftsave**: (default: 1) Save feature matrices for machine learning (logical).
        
        - **opts.filter.tr**: Repetition time (TR) in seconds. Used to compute the sampling frequency for filtering.
        - **opts.filter.highpass**: High-pass filter cutoff frequency in Hz. Can be a numeric value or the string `'none'`. If numeric, a Butterworth filter is applied.
        - **opts.filter.lowpass**: Low-pass filter cutoff frequency in Hz. Can be a numeric value or the string `'none'`. If numeric, a Butterworth filter is applied.
        - **opts.filter.order**: (Optional, default: 1) Order of the Butterworth filter. Applies to high-pass, low-pass, or band-pass configurations.

        - **opts.regout.conf**: Table, matrix, or cell array of confound files (numeric or table) to be regressed out via GLM. If multiple subjects are processed, must be a cell array with one entry per subject.
        - **opts.regout.selconf**: Vector of column indices to select specific confounds from `conf`. Can be empty to use all columns.
        - **opts.regout.demean**: (default: false) Logical flag indicating whether to include a constant (intercept) regressor for mean removal during regression.

        - **opts.zscore**: Logical flag. If true, the time series inside each ROI is z-scored (zero mean, unit std) after all other preprocessing steps.

        
    - **hObject:** (Optional - default: NaN) Handle to the graphical user 
                 interface object. Not provided for command line usage.

- **Outputs:**
    - The runconnectome saves the computed connectomes and feature matrices in the specified output directory. The filenames include 'rconnec.mat', 'pconnec.mat', 'zconnec.mat', and their corresponding feature matrices as 'rfeatmat.mat', 'pfeatmat.mat', 'zfeatmat.mat', and their CSV versions.


Axes Screenshot
----------------

### Overview

The `axes_screenshot` toolbox is a set of MATLAB functions designed to capture and save screenshots of different axes configurations within the fMROI application. It can save slices programmatically, generate mosaic and slice sequences, and save them to most used image formats like PNG, JPEG, and TIFF. For more details about supported file formats, refer to the MATLAB `imwrite` function documentation.


### Usage

To open the Axes Screenshot Tool, go to fMROI main menu ´Tools´ and select ´axes_screenshot´.

**Generating Single Slices Screenshots**

In the dropdown menu labeled "Mode", select "Axes".
To open the Single Slices Screenshots tool and set the Parameters:

- Select the axes to be saved: Tick the checkboxes "Axes" related to the axes that you want to save (Axi - Axial; Cor - Coronal; Sag - Sagittal; Vol - Volumetric render).
- Select the slices to be saved: In the radio button group "Slices", select "Current slices" to save the slices that are displayed in the fMROI axes, or check "Select slices" to manually enter the slices to be saved. Selecting "Select slices" enables the fields "Axi", "Cor", and "Sag" to manually enter the slices number to be saved. The slice number must be provided in voxel coordinates (matrix index) separeted by comas (,). To specify a range of slices, use a colon (:) between the starting and ending slice number. Example: To save axial slices 10, 16, 20, 21, 22, 23, 24, 25, 30, 35, 40, 45, 50 you can enter each slice separated by comas or simply `10,16,20:25,30:5:50` in the "Axi" field.

Once the parameters are set, enter the full output file name in the "Out path" field (default: ./fmroiscreenshot.png). Click the "Save" button to save each selected slice to a separate file. Each filename will be appended with a suffix identifying the axis type and slice number (e.g., saving slice 10 from the axial axis with the default name would result in "fmroiscreenshot_axi10.png").


**Generating a Multislice Screenshot**

In the dropdown menu labeled "Mode", select "Multi-slice".
To open the Multislice tool and set the Parameters:

- Number of Slices: Enter the number of slices to capture in the "Slices" field.
- Initial Slice: Enter the starting slice number in the "Init Slice" field.
- Last Slice: Enter the ending slice number in the "Last Slice" field.
- Target slice: Select the target slice type (Axial, Coronal, or Saggital) from the "Target slice" drop dow menu. 
- Slice Overlap: Enter the slice overlap percentage (between captured slices) in the "Slice Overlap" field. The slider below the 'Overlap' field allows you to adjust this value interactively.

Once the parameters are set, click the "Gen" button to generate the multislice picture. The "Slice Overlap" slider can be used to adjust the position of the slices. If you want to invert the the slices order, set any negative value (between 0 and -1) in the "Overlap" field.
Once you are happy with the resulting picture, enter the full output file name in the "Out path" field (default: ./fmroiscreenshot.png). Click the "Save" button to save the multislice screenshots to the specified file.


**Generating a Mosaic Screenshot**

In the dropdown menu labeled "Screenshot Mode", select "Mosaic".
To open the Mosaic tool and set the Parameters:

- Columns: Enter the number of columns in the mosaic in the "Columns" field.
- Lines: Enter the number of lines in the mosaic in the "Lines" field.
- Initial Slice: Enter the starting slice number in the "Init slice" field.
- Last Slice: Enter the ending slice number in the "Last slice" field.
- Target slice: Select the target slice type (Axial, Coronal, or Saggital) from the "Target slice" drop dow menu.
- Column Overlap: Enter the column overlap percentage in the "Column Overlap" text box.
- Line Overlap: Enter the line overlap percentage in the "Line Overlap" text box.

Once the parameters are set, click the "Gen" button to generate the mosaic picture. The mosaic will be displayed in the main axes of the GUI, and its slices' positions can be adjusted by moving the "Overlap" slider. If you want to invert the horizontal or vertical order of the slices, set any negative value (between 0 and -1) in the "Column Overlap" and "Line Overlap" fields respectively.
Once you are happy with the resulting picture, enter the full output file name in the "Out path" field (default: ./fmroiscreenshot.png). Click the "Save" button to save the mosaic screenshots to the specified file.


***Notes*** - *Ensure all required fields are filled before generating or saving screenshots. Adjust overlap percentages carefully to avoid overlapping images improperly.*