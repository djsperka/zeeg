function [c] = findIndexClusters(indices)

% findIndexClusters Finds clusters of indices in the input array. 
%
% Clusters are dumb and simple - sets of indices that differ by one. The
% input assumed to consist of peaks of a noisy distribution, and when the
% peak of a pulse, which rises above the noise, is clipped off and its
% indeces passed here, we expect the indices of that little peak to be
% adjacent, e.g. 9,10,11. Indices may be isolated - just one in a peak. 
% Returns cell array with 2 rows, N columns. Each column represents a
% cluster, or peak. The first row is the center of the cluster (average of
% the indices), the second row is the indices in the cluster. 

    % diffs is the difference between one index and the previous index. 
    % seed the first diff with a large number - it is the start of a cluster
    % by definition. 
    diffs=zeros(1, length(indices));
    diffs(1)=999;
    diffs(2:end)=indices(2:end)-indices(1:end-1);

    % The start of a cluster is at each point/index where 'diffs' is greater
    % than 1. 
    cluster_start_indices=find(diffs>1);

    % generate output cell array
    c = cell(2, length(cluster_start_indices));
    for i=1:length(cluster_start_indices)
        c1 = cluster_start_indices(i);
        if i==length(cluster_start_indices)
            c{2, i} = indices(cluster_start_indices(i):end);
        else
            c{2, i} = indices(cluster_start_indices(i):cluster_start_indices(i+1)-1);
        end
        c{1, i} = mean(c{2, i});
    end

end