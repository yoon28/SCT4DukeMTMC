function result = solveInGroups(dataset, tracklets, labels, VISUALIZE)

global trajectorySolverTime;

params = dataset.trajectories;
if dataset.useGrouping == false || length(tracklets) < params.appearanceGroups
    params.appearanceGroups = 1;
end

% adaptive number of appearance groups
params.appearanceGroups = 1 + floor(length(tracklets)/120);

% fixed number of appearance groups
featureVectors      = {tracklets.feature};
appearanceGroups    = kmeans( cell2mat(featureVectors'), params.appearanceGroups, 'emptyaction', 'singleton', 'Replicates', 10);

% solve separately for each appearance group
allGroups = unique(appearanceGroups);

result_appearance = cell(1, length(allGroups));
for i = 1 : length(allGroups) % ; yoon
    
    fprintf('merging tracklets in appearance group %d\n',i);
    group       = allGroups(i);
    indices     = find(appearanceGroups == group);
    sameLabels  = pdist2(labels(indices), labels(indices)) == 0;
    
    % compute appearance and spacetime scores
    appearanceAffinity = getAppearanceMatrix(featureVectors(indices), params.distanceType, params.alpha);
    [spacetimeAffinity, impossibilityMatrix, indifferenceMatrix] = getSpaceTimeAffinity(tracklets(indices), params.beta, params.speedLimit, params.indifferenceTime);
    
    % compute the correlation matrix
    correlationMatrix = appearanceAffinity + spacetimeAffinity - 1;
    correlationMatrix = correlationMatrix .* indifferenceMatrix;
    
    correlationMatrix(impossibilityMatrix == 1) = -inf;
    correlationMatrix(sameLabels) = 10;
    
    % show appearance group tracklets
    if VISUALIZE
        if dataset.halfFrameRate
            trajectoriesVisualizePart2_30fps;
        else
            trajectoriesVisualizePart2;
        end
    end
    
    % solve the optimization problem
    solutionTime = tic;
    greedySolution = AL_ICM(sparse(correlationMatrix));
    
    if strcmp(dataset.method,'AL-ICM')
        result_appearance{i}.labels  = greedySolution;
    elseif strcmp(dataset.method,'BIP')
        result_appearance{i}.labels  = solveBIP(correlationMatrix,greedySolution);
    end
    
    trajectorySolutionTime = toc(solutionTime);
    trajectorySolverTime = trajectorySolverTime + trajectorySolutionTime;
    
    result_appearance{i}.observations = indices;
end


% collect independent solutions from each appearance group
result.labels       = [];
result.observations = [];

for i = 1:numel(unique(appearanceGroups))
    result = mergeResults(result, result_appearance{i});
end

[~,id]              = sort(result.observations);
result.observations = result.observations(id);
result.labels       = result.labels(id);


