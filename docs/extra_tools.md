Extra Tools
============

Applymask
----------

Applymask (or runapplymask for command line use) function applies masks to a set of source images, extracting time-series data and statistical measures from these masked regions, and saving the results to a specified output directory.

- **Syntax:**
    - *runapplymask(srcpath,maskpath,outdir,opts,hObject)*

- **Inputs:**
    - **srcpath:** String containg the paths to the source images separeted by semicolons, or a path to a text file (.txt, .csv, or .tsv) containing the images paths in a line (separated by tabs or semicolons) or in a column (1D array).
    - **maskpath:** String containg the paths to the mask images separeted by semicolons, or a path to a text file (.txt, .csv, or .tsv) containing the maskpaths paths separated by tabs orsemicolons. The number of mask paths must exactly match the number of source images or there can be only one mask. Each mask in the list is applied to the corresponding source image in the same order (i.e., first mask to first image, second mask to second image, and so on). If the maskpath points to a text file, each column represents a different mask type and will be processed separately. Each column can have as many lines as there are source images or only one mask to be applied to all images.
    - **outdir:** Path to the output directory (string).
    - **opts:** (optional) A structure containing options for saving outputs.
        - *opts.saveimg:* (default: 1) Flag indicating if masked images should be saved (logical, 1 to save, 0 to not save).
        - *opts.savestats:* (default: 1) Flag indicating if statistics should be saved (logical, 1 to save, 0 to not save).
        - *opts.savets:* (default: 1) Flag indicating if time series data should be saved (logical, 1 to save, 0 to not save).
        - *opts.groupts:* (default: 0) Flag used to control how the time series data is saved. If opts.groupts is set to 1, then thetime series data will be saved grouped by source image. This means that all of the masks for a particular source image will be saved together in a single file. However, if opts.groupts is set to 0, then the time series data will be saved for each mask separately. This means that there will be a separate file for each mask.
    - **hObject:** (Optional - default: NaN) Handle to the graphical user interface object. Not provided for command line usage.

 - **Outputs:** runapplymask saves to the output directory the following data:
    - Masked images (if opts.saveimg is set to 1).
    - Timeseries.mat file containing the source paths, mask paths, and time series data (if opts.savets is set to 1).
    - Median.csv, Mean.csv, Std.csv, Max.csv, Min.csv files containing statistics for each mask applied to each source image (if opts.savestats is set to 1).

*This function requires SPM 12 to be installed.*