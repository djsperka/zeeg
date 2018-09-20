function [allIndices, allK] = esSyncTest(blob)
% esSyncTest computes final sync values, testing script

subblob = blob{1, 4};
tSMRPulses = blob{1, 1};
indexSMRBase = blob{1, 2};
tEEGBase = blob{1, 3};
tSMRBase = tSMRPulses(indexSMRBase);

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
            fprintf(1, '%f %f %f %f %f\n', tSMRPulses(indexFoundPulses(j)), tSMRBase, tFoundPulses(j), tEEGBase, allK(count)-.001);
        end
    end
end

figure;
plot(allIndices, allK);
ylim([0.9, 1.1]);
