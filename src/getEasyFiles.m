function [f] = getEasyFiles(d)

% getEasyFiles - return list of EEG files in directory d
% L=getFiles(DIRECTORY) Looks in DIRECTORY (char vector) for a set of EEG
% files. Assumes that the files will contain two baseline files, one for
% Trial 1 and one for the End, named something like 
%
% prefix_Baseline_EEG_Trial_1.easy
% prefix_Baseline_EEG_End.easy
%
% and a series of trial files named
%
% prefix_EEG_Trial_n.easy
%
% Returns full filenames (using DIRECTORY) as a cell array.

baseline_t1 = '*_v2_Baseline_EEG_Trial_1.easy';
baseline_t1_fullfile = fullfile(d, baseline_t1);
baseline_t1_dir = dir(baseline_t1_fullfile);
if (isempty(baseline_t1_dir))
    error('*_v2_Baseline_EEG_Trial_1.easy not found\n');
end


baseline_end = '*_v2_Baseline_EEG_End.easy';
baseline_end_fullfile = fullfile(d, baseline_end);
baseline_end_dir = dir(baseline_end_fullfile);
if (isempty(baseline_end_dir))
    error('*_v2_Baseline_EEG_End.easy not found\n');
end

% Now get all trial files
eeg_trial = '*_v2_EEG_Trial_*.easy';
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
re='\.*_v2_EEG_Trial_([0-9]+)\.easy';
for i=1:length(eeg_trial_dir)
    strial = regexp(eeg_trial_dir(i).name, re, 'tokens');
    if (length(strial) ~= 1)
        error('Error extracting trial number from file %s\n', eeg_trial_dir(i).name);
    end
    trial = str2num(char(strial{1}));
    f{i+1} = fullfile(d, eeg_trial_dir(i).name);
end

return;

