function [data, eegSignal, eegSignalSub, t] = getEasyEEGData(filename, nslide)
% getEasyEEGData Load easy file, return signal, signal with moving avg
% subtracted, and timestamps. 'nslide' is width of sliding window for avg.

data=importdata(filename);
if (size(data, 2) ~= 13)
    error('Error - easy file should have 13 columns, file %s has %d', filename, size(data, 2));
end

% s is the eeg signal itself
% ss is the signal with the moving average subtracted
eegSignal=data(:, 7);
t = data(:, 13);
slide = movmean(eegSignal, nslide);
eegSignalSub = eegSignal-slide;

end

