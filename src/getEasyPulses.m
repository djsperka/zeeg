function [clusters] = getEasyPulses(filename, nslide, lodiffthresh)
% getEasyPulses Finds pulses in easy file 'filename'

clusters={};
d=importdata(filename);
if (size(d, 2) ~= 13)
    error('Error - easy file should have 13 columns, file %s has %d', filename, size(d, 2));
end

% s is the eeg signal itself
% ss is the signal with the moving average subtracted
s=d(:, 7);
slide = movmean(s, nslide);
ss = s-slide;

mmdiff = max(ss)-min(ss);

% do it in 100 steps
% There is an optimization to be had here - for now just run through all
% cutoff levels from the peak down to the min. 
mmdiffstep = mmdiff/100;

levels=max(ss):-mmdiffstep:min(ss);
ngreater = zeros(length(levels), 1);
for l=1:length(levels)
    indices = find(ss>levels(l));
    tmpclusters = findIndexClusters(indices);
    clusteravgs = cell2mat(tmpclusters(1, 1:end));
    if length(clusteravgs)>1
        avgdiffs = clusteravgs(2:end)-clusteravgs(1:end-1);
        if ~isempty(find(avgdiffs<lodiffthresh, 1))
            break;
        end
    end
    ngreater(l) = length(clusteravgs);
    clusters = tmpclusters;
end

    
figure;
subplot(4, 1, 1);
plot(s);
subplot(4, 1, 2);
plot(ss);
subplot(4, 1, 3);
plot(ngreater);
ylim([0 100]);

clusteravgs = cell2mat(clusters(1, 1:end));
avgdiffs=[];
if length(clusteravgs)>1
    avgdiffs = clusteravgs(2:end)-clusteravgs(1:end-1);
end
subplot(4, 1, 4);
histogram(avgdiffs, [50:100:5000]);

end
 