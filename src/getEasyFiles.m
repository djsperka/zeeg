function [f] = getEasyFiles(d, distinguishingText)

% getEasyFiles - return list of EEG files in directory d
% L=getEasyFiles(DIRECTORY, TEXT) Looks in DIRECTORY (char vector) for a set of EEG
% files. The files are assumed to have a naming scheme that looks like
% this - 
% <something><distinguishingText>_Baseline_EEG_Trial_1.easy   (first file)
% <something><distinguishingText>_Baseline_EEG_End.easy       (last file)
% <something><distinguishingText>_EEG_Trial_n.easy            (n=2,3,...)
%
% distinguishing text is for cases where there is more than one set of easy
% files, and one has _v2_ or something plastered in there before the
% "Baseline" or "EEG_Trial" parts of the filename. 
%
% Returns full filenames (using DIRECTORY) as a cell array.

baseline_t1 = strcat('*', distinguishingText, '_Baseline_EEG_Trial_1.easy');
baseline_t1_fullfile = fullfile(d, baseline_t1);
baseline_t1_dir = dir(baseline_t1_fullfile);
if (isempty(baseline_t1_dir))
    error('*_v2_Baseline_EEG_Trial_1.easy not found\n');
end


baseline_end = strcat('*', distinguishingText, '_Baseline_EEG_End.easy');
baseline_end_fullfile = fullfile(d, baseline_end);
baseline_end_dir = dir(baseline_end_fullfile);
if (isempty(baseline_end_dir))
    error('*_v2_Baseline_EEG_End.easy not found\n');
end

% Now get all trial files
eeg_trial = strcat('*', distinguishingText, '_EEG_Trial_*.easy');
eeg_trial_fullfile = fullfile(d, eeg_trial);
eeg_trial_dir = dir(eeg_trial_fullfile);
if (isempty(eeg_trial_dir))
    error('*_v2_EEG_Trial_*.easy file(s) not found\n');
end

% Create cell array of filenames
f = cell(2+length(eeg_trial_dir), 1);

% Fill cell array with filenames
f{1} = fullfile(d, baseline_t1_dir.name);
f{length(f)} = fullfile(d, baseline_end_dir.name);
re='\.*EEG_Trial_([0-9]+)\.easy';
for i=1:length(eeg_trial_dir)
    strial = regexp(eeg_trial_dir(i).name, re, 'tokens');
    if (length(strial) ~= 1)
        error('Error extracting trial number from file %s\n', eeg_trial_dir(i).name);
    end
    trial = str2num(char(strial{1}));
    f{i+1} = fullfile(d, eeg_trial_dir(i).name);
end

return;

