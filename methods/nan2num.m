function outdata = nan2num(indata)
% nan2num converts all array NaNs to zeros.
%
% Syntax:
%   outdata = nan2num(indata)
%
% Inputs:
%    indata: Numeric matrix.
%
% Outputs:
%   outdata: Numeric matrix with same size of the indata.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

indata(isnan(indata)) = 0;

outdata = indata;