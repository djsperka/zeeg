# zeeg
Matlab scripts synchronizing data from Enobio EEG device with SMR data from electrophys rig. 

There are two scripts intended for regular use. 

The 'esSync' script looks at an entire set of EEG data and its corresponding SMR export file, and computes an offset and scale factor to transform the EEG data into the time coords of the 1401 data. The result is a single mat file that is used later when EEG data is to be fetched. 

The 'getEEGData' script uses the output from 'esSync' and fetches EEG data from specific time blocks. The time periods are specified in SMR time, and the script converts the SMR time to EEG time, and returns the data. A vector with corresponding time values (converted to SMR time) is also returned. 

**Background**

The 1401 and the Enobio each operate with their own clocks. Since the 1401 is central to our experiments, and all behavior and stimulus-related events are recorded there, analysis will typically call for data from time periods defined in SMR time units. Thus, I gear this conversion to convert FROM eeg time units TO smr units. 

Assume that clock in EEG data is shifted and has a simple linear scale factor from the "good" 1401-based clock. 

t(SMR)-t(SMR,base) = K * [ t(eeg)-t(eeg,base) ]

The data stream has a regular series of TTL pulses that are simultaneously recorded by the 1401 and by the Enobio. Thus, we have many data points to use for computing the scale factor K. The offset is determined using input given by the user. The series of pulses that are recorded start with a sequence of 3 pulses close together, and are followed by pulses separated by about a second. The PLAN was that those three pulses would serve as an anchor - allowing for a clear identification of the same time point in both files - and hence determining the offset between the files. Unfortunately, the EEG data files in practice are too noisy for a clean, consistent identification of the pulse group. Instead, a user is asked to identify a single pulse in the train and specify *which pulse it is* in the sequence. (The easiest thing is to identify the first or second pulse in the train -- its important that the EXACT position in the train is known). 

I apply a quick-and-dirty algorithm to locate pulses in the EEG data. 




Note that it is not critical that ALL pulses be identified. To a good first approximation the scale factor between the clocks is 1 (actually, its 0.001, because the SMR data in the mat file exported are converted to seconds, whereas the Enobio EEG data is marked with a time coordinate in milliseconds. Consequently, the position of the pulses in the sequence recorded in the EEG file can be identified with high confidence. Once a pulse is identified as a particular pulse, for example, the 10th pulse. The time value of the 10th pulse in the SMR data is known, and the value of K can be computed for that pulse. This computation is repeated for each pulse that is identified in the EEG file. 





Enobio EEG device dumps data to a folder with *.easy* files. 
File naming follows pattern of Stim-Trial-Stim-Trial.......
We only look at _Trial_ files (no electrode recording during stimulation)

The signals/pulses can be crappy. Don't sweat too hard, instead rely on consistency internally. 
Load voltage stream for pulse channel, this channel _should_ have the TTL pulses generated by the script.

Get sliding average and subtract it off. Take max/min of remaining signal, split into steps. 
Step down from top to bottom, at each step find points above threshold. Clusters assumed to be adjacent
indices. Check distance between clusters, quit when clusters closer together than a min distance. 

Need more data to test with. 

To run, 

>> blob=esSync('./../data', 'Dr. Zaius_eeg_000_20180126.mat');
>> [allIndices, allK] = esSyncTest(blob);

That should generate a plot of k - conversion factor between files.
