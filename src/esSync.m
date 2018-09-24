function [s] = esSync(folder, smrfile, v2Txt)
% esSync computes synchronization params for (e)eg&(s)mr files.
%
% folder - folder where easy files and smr-exported mat file found
% smrfile - mat filename of exported file
%
% Returns a struct with these fields:
% 'files' = struct with fields 'filename' and 'limits'
% 'K' = conversion factor
% 'tEEGBase' = eeg base time
% 'tSMRBase' = smr base time
%


nslide = 50;
lodiffthresh = 490;
approxEEGStep = 1000;
approxEEGWidth = 10;   % accept this wide for averaging
smrSkipMarkers = 3;
minPulsesInEasyFile = 15;

ezFiles = getEasyFiles(folder, v2Txt);

% Identify base pulse. ezFiles{1} is the baseline eeg file. Prompt user to
% identify a particular pulse and specify what its position is, counting
% the first pulse after the "bunch" to be pulse 1, the next is 2, etc. Pick
% a pulse after the base (this can be changed, must account for smaller
% step from 0->1. 
%
% getAnchorPulse returns the position index of the base pulse chosen (using
% the
% expected pulse pattern in smr file, i.e. the pulse after the initial
% grouping is pulse "1". The var 'markerTsmr' obeys this convention. 

fprintf(1, 'Get user input - where is anchor pulse in file: %s\n', ezFiles{1});
[indexSMRBase, tEEGBaseSelected] = getAnchorPulse(ezFiles{1});
[clusters, tclusters] = getEasyPulses(ezFiles{1}, nslide, lodiffthresh);
%avgs = cell2mat(clusters(1, :));
[mindiff, indexEEGBase] = min(abs(clusters-tEEGBaseSelected));
tEEGBase = tclusters(indexEEGBase);
fprintf(1, 'tEEG idx selected %f\n', tEEGBaseSelected);
fprintf(1, 'tEEG idx closest  %f, i=%d\n', clusters(indexEEGBase), indexEEGBase);

% Get likely step size in eeg time
avgdiffs = tclusters(2:end) - tclusters(1:end-1);
eegStepSize = mean(avgdiffs(find(abs(avgdiffs-approxEEGStep)<approxEEGWidth)));
eegStepSizeStd = std(avgdiffs(find(abs(avgdiffs-approxEEGStep)<approxEEGWidth)));
fprintf(1, 'eeg step size %f std %f\n', eegStepSize, eegStepSizeStd);

%smrData - get pulase marker times - in 'smr time'
% Expecting a bunch of pulses - 3 - followed by the 1s pulses.
% markerTsmr will clip off the initial bunch, so indexing of pulses starts
% at the first pulse _after_ the bunch

fprintf(1, 'loading smr file %s\n', fullfile(folder, smrfile));
smrData = load(fullfile(folder, smrfile));
tSMRPulsesTmp = smrData.Dr_Ch25.times(find(smrData.Dr_Ch25.level==1));
tSMRPulses = tSMRPulsesTmp(smrSkipMarkers+1:end);
tSMRBase = tSMRPulses(indexSMRBase);

% Now load each eeg file. Find pulses. For each pulse, estimate its index
% using the eegStepSize and the base pulse. Given that estimate, compute k.
% Save up values of k for entire file (for all files, actually)

% For each file, find pulses and loop over their times. They should be
% approx 'eegStepSize' apart, but some may be missing; the gap is
% expected to be a multiple of 'eegStepSize', or close to that. The first
% file uses the user-id'd pulse and the time of its nearest pulse as the
% reference. At the end of processing each file, reset the reference index
% and time to the last pulse in the file just processed. Any slow drift in
% the estimated indices should be eliminated as a problem. 
%


indexReference = indexSMRBase;
tReference = tEEGBase;

indexLastReference = indexReference;
tLastReference = tReference;

blob = cell(1, 4);
blob{1, 1} = tSMRPulses;
blob{1, 2} = indexSMRBase;
blob{1, 3} = tEEGBase;
subblob = cell(length(ezFiles), 4);

s = struct;
f = struct;


for i=1:length(ezFiles)
    fprintf(1, 'Look at ez file: %s\n', ezFiles{i});
    [clusters, tclusters, tStart, tEnd] = getEasyPulses(ezFiles{i}, nslide, lodiffthresh);
    fprintf(1, 'Found %d pulses\n', length(clusters));
    f(i).filename = ezFiles{i};
    f(i).limits = [tStart, tEnd];

    if length(clusters) > minPulsesInEasyFile
    
%      for the first file, the one used to id the base pulse, start the
%      indexing at the index of the pulse id'd by the user. For all other
%       files, start indexing at 1.

        indexStart = 1;
        if i==1
            indexStart = indexEEGBase;
        end

        % cell elements saved for each file:  
        % time in EEG of found pulses
        tFoundPulses=zeros(length(clusters)-indexStart+1, 1);
        % estimated index, in SMR pulse count, of found pulses
        indexFoundPulses=zeros(length(clusters)-indexStart+1, 1);


        for j = indexStart:length(clusters)
            indexEstimated = indexReference + (tclusters(j)-tReference)/eegStepSize;
            %fprintf(1, '%f ', indexEstimated);

            % Skip over index <=0 - that's the base itself, and stuff (if there is any) before it. 
            if round(indexEstimated) > 0
                % save this index and its time
                tFoundPulses(j-indexStart+1) = tclusters(j);
                indexFoundPulses(j-indexStart+1) = round(indexEstimated);

            else
                % shouldn't happen now that I use indexEEGBase
                error('FOUND NEG/0 INDEX\n');
            end

        end    

        % re-establish the last index here as the new reference
        indexReference = indexFoundPulses(end);
        tReference = tFoundPulses(end);

        % assign values to blob
        subblob{i, 1} = ezFiles{i};
        subblob{i, 2} = tFoundPulses;
        subblob{i, 3} = indexFoundPulses;
        subblob{i, 4} = [tStart, tEnd];
        
    end
end


% Now the blob has info on all pulses identified in the EEG files, and the
% associated pulses in the SMR file.
% We also have the t, in EEG, of a particular pulse identified by the user.
% For every pulse in the EEG files, compute the scale factor between the
% clocks:
% tS -tSB = K(tE - tEB)
% where tS = time value in SMR 
%       tSB = time (in SMR) of base pulse
%       tE = time in EEG corresponding to tS
%       tEB = time (in EEG) of base pulse
% 
% Expect the value of K to hit an asymptote, but with larger values for
% indices closer to the base pulse. 


% how many indices in total?
nTotal = 0;
for i=1:size(subblob, 1)
    nTotal = nTotal + size(subblob{i, 3}, 1);
end
% allocate space for all points except the id'd base pulse
allIndices = zeros(nTotal-1, 1);
allK = zeros(nTotal-1, 1);

count = 0;
for i=1:size(subblob, 1)
    tFoundPulses = subblob{i, 2};
    indexFoundPulses = subblob{i, 3};
    for j=1:length(tFoundPulses)
        if (i>1 || j>1)
            count = count+1;
            allIndices(count) = indexFoundPulses(j);
            allK(count) = (tSMRPulses(indexFoundPulses(j)) - tSMRBase)/(tFoundPulses(j)-tEEGBase);
            fprintf(1, '%f %f %f %f %f\n', tSMRPulses(indexFoundPulses(j)), tSMRBase, tFoundPulses(j), tEEGBase, (allK(count)-.001)*1000000);
        end
    end
end

figure;
plot(allIndices, allK);


fprintf(1, 'Use K value at index %d: %f\n', allIndices(end), allK(end));

s.files = f;
s.K = allK(end);
s.tSMRBase = tSMRBase;
s.tEEGBase = tEEGBase;





end