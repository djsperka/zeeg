function [tSMR] = toSMRTime(syncStruct, tEEG)
%toSMRTime Convert EEG time to SMR time. 

    tSMR = syncStruct.tSMRBase + syncStruct.K * (tEEG - syncStruct.tEEGBase);

end

