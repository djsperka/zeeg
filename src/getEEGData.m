function [tSMR, data] = getEEGData(syncStruct, channels, endpoints)
%getEEGData gets EEG data between endpoints (which should be in SMR time). 
% Returns time values in SMR time. The data for each channel in 'channels'
% is returned in the corresponding row in 'data'.

% convert endpoints of the time span to SMR 

t1EEG = toEEGTime(syncStruct, endpoints(1));
t2EEG = toEEGTime(syncStruct, endpoints(2));
eegTimes = [];
data = [];

for i = 1:length(syncStruct.files)
%     fprintf(1, 'check %s %d-%d SMR %f-%f\n', ...
%         syncStruct.files(i).filename, ...
%         syncStruct.files(i).limits(1), ...
%         syncStruct.files(i).limits(2), ...
%         toSMRTime(syncStruct, syncStruct.files(i).limits(1)), ...
%         toSMRTime(syncStruct, syncStruct.files(i).limits(2)));
    if (t1EEG < syncStruct.files(i).limits(2)) && (t2EEG > syncStruct.files(i).limits(1))
        fprintf(1, 'Need file %s\n', syncStruct.files(i).filename);
        [d, ~, ~, t] = getEasyEEGData(syncStruct.files(i).filename, 50);
        first = find(t >= t1EEG, 1, 'first');
        last = find(t <= t2EEG, 1, 'last');
        eegTimes = [eegTimes t(first:last)];
        data = [data d(first:last, channels)];
    end
end

tSMR = toSMRTime(syncStruct, eegTimes);

end
