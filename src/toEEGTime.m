function [ tEEG ] = toEEGTime( syncStruct, tSMR )
%toEEGTime Convert smr time to EEG time for the syncStruct given.

    tEEG = (tSMR - syncStruct.tSMRBase)/syncStruct.K + syncStruct.tEEGBase;

end

