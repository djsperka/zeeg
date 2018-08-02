function [pulses] = getEasyPulses(filename, nslide)
% getEasyPulses Finds pulses in easy file 'filename'

d=importdata(filename);
if (size(d, 2) ~= 13)
    error('Error - easy file should have 13 columns, file %s has %d', filename, size(d, 2));
end

% s is the eeg signal itself
% ss is the signal with the moving average subtracted
s=d(:, 7);
slide = movmean(s, nslide);
ss = s-slide;

mmdiff = max(ss)-min(ss)

% do it in 100 steps
mmdiffstep = mmdiff/100;

levels=max(ss):-mmdiffstep:min(ss);
ngreater = zeros(length(levels), 1);
for l=1:length(levels)
    ngreater(l) = length(find(ss>levels(l)));
end

    
figure;
subplot(3, 1, 1);
plot(s);
subplot(3, 1, 2);
plot(ss);
subplot(3, 1, 3);
plot(ngreater);
ylim([0 100]);


pulses=[];

end
 