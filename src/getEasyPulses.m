function [clusters, tclusters, tStart, tEnd] = getEasyPulses(filename, nslide, lodiffthresh)
% getEasyPulses Finds pulses in easy file 'filename'. Returns the indices
% and the time values for each pulse. As a convenience, return the start
% and end times of the easy file (in EEG time). 

clusters=[];
d=importdata(filename);
if (size(d, 2) ~= 13)
    error('Error - easy file should have 13 columns, file %s has %d', filename, size(d, 2));
end
tStart = d(1, 13);
tEnd = d(end, 13);

% s is the eeg signal itself
% ss is the signal with the moving average subtracted
s=d(:, 7);
slide = movmean(s, nslide);
ss = s-slide;

% figure;
% subplot(2, 1, 1);
% plot(s);
% subplot(2, 1, 2);
% plot(ss);

mmdiff = max(ss)-min(ss);

% do it in 100 steps, from the max down to the min. 
% As we step down we should pick up more and more peaks.
% There is an optimization to be had here - for now just run through all
% cutoff levels from the peak down to the min. 
mmdiffstep = mmdiff/100;

levels=max(ss):-mmdiffstep:min(ss);
ngreater = zeros(length(levels), 1);
for l=1:length(levels)
    
    % levels(l) is the threshold for picking up an index. 
    indices = find(ss>levels(l));
    if isempty(indices)
        continue;
    end
    
    % clump the indices together. 
    % clumping is dumb, assumes adjacent groups are a single peak. 
    tmpclusters = findIndexClusters(indices);
    %fprintf(1, 'Got %d tmpclusters\n', length(tmpclusters));
    clusteravgs = cell2mat(tmpclusters(1, 1:end));
    
    % If there is more than one cluster found, assume that each cluster
    % is a pulse and check the difference between them. If any are
    % _closer_together_ than the 'lodiffthresh', take it as a sign that
    % we've fallen into some noisy hole and should stop here. 
    % TODO - just skip the rest? Skip file entirely? 
    if length(clusteravgs)>1
        avgdiffs = clusteravgs(2:end)-clusteravgs(1:end-1);
        if ~isempty(find(avgdiffs<lodiffthresh, 1))
            %fprintf(1, 'NOISY\n');
            break;
        end
    end
    ngreater(l) = length(clusteravgs);
    clusters = clusteravgs;
end

%if length(clusters)==1
%    fprintf(1, 'single cluster index %f\n', clusters(1));
%end

% The cluster averages are indices, not time values. 
cr = round(clusters);
tclusters=d(cr, 13) + 2*(clusters-cr)';

% figure;
% subplot(4, 1, 1);
% plot(s);
% subplot(4, 1, 2);
% plot(ss);
% subplot(4, 1, 3);
% plot(ngreater);
% ylim([0 100]);
% 
% clusteravgs = cell2mat(clusters(1, 1:end));
% avgdiffs=[];
% if length(clusteravgs)>1
%     avgdiffs = clusteravgs(2:end)-clusteravgs(1:end-1);
% end
% subplot(4, 1, 4);
% histogram(avgdiffs, [50:100:5000]);

end
 