function [dataClean,indOutOfRangeMin,indOutOfRangeMax] = findOutOfRangePoints(tv, dataIn, minMax)
% [dataClean,indOutOfRange] = findOutOfRangePoints(tv, dataIn, minMax)
%
% This function finds the values in dataIn that are outside of the minMax range.
% minMax can be a row ([minValue maxValue]) or a 12x2 matrix where each row is
% [monthlyMinValue monthlyMaxValue].
% The output dataClean has NaN values where the dataIn values were outside of the range.
% 
% Inputs:
%   tv                  - the time vector (usually 30-min, always end-times)
%   dataIn              - data vector to be cleaned
%   minMax              - ether 1x2 row or 12x2 matrix (see notes above)
%
% Outputs:
%   dataClean           - vector dataIn with all out-of-range points set to NaN
%   indOutOfRangeMin    - index of the points below minimum values
%   indOutOfRangeMax    - index of the points below maximum values
% 
%
% Zoran Nesic           File created:       Mar 31, 2026
%                       Last modification:  Mar 31, 2026

%
% Revisions:
%

% Ensure column vectors
tv = tv(:);
dataIn  = dataIn(:);

% Shift timestamps slightly backward (1 second)
tvAdjusted = tv - 1/86400;

% minMax can be 1x2 row or 12 x 2 matrix of min and max values
if ~all(size(minMax) == [1 2]) && ~all(size(minMax) == [12 2])
    error('minMax dimensions have to be 1x2 or 12x2!')
end

if size(minMax,1) == 12
    % Get month number (end-time corrected)
    currentMonth = month(tvAdjusted);

    % Monthly limits per data point
    minVals = minMax(currentMonth, 1);
    maxVals = minMax(currentMonth, 2);
else
    minVals = minMax(1);
    maxVals = minMax(2);
end

% Find violations
indOutOfRangeMin = find(dataIn < minVals);
indOutOfRangeMax = find(dataIn > maxVals);
dataClean = dataIn;
dataClean(indOutOfRangeMin) = NaN;
dataClean(indOutOfRangeMax) = NaN;

