function  tracklets = createTracklets(dataset, originalDetections, allFeatures, startFrame, endFrame, tracklets, VISUALIZE)
% CREATETRACKLETS This function creates short tracks composed of several detections.
%   In the first stage our method groups detections into space-time groups.
%   In the second stage a Binary Integer Program is solved for every space-time
%   group.

%% DIVIDE DETECTIONS IN SPATIAL GROUPS
% init variables
params          = dataset.tracklets;
totalLabels     = 0; currentInterval = 0;

% convert startFrame and endFrame to the synchronized time
if dataset.halfFrameRate
    startFrame  = startFrame    + syncTime30fps(dataset.camera); % yoon
    endFrame    = endFrame      + syncTime30fps(dataset.camera); % yoon
else
    startFrame  = startFrame    + syncTimeAcrossCameras(dataset.camera);
    endFrame    = endFrame      + syncTimeAcrossCameras(dataset.camera);
end

% find detections for the current frame interval
currentDetectionsIDX    = intervalSearch(originalDetections(:,2), startFrame, endFrame);

% skip if no more than 1 detection are present in the scene
if length(currentDetectionsIDX) < 2, return; end

% compute bounding box centeres
detectionCentersImage   = getBoundingBoxCenters(originalDetections(currentDetectionsIDX, 3:6)); 
detectionCenters        = detectionCentersImage;
detectionFrames         = originalDetections(currentDetectionsIDX, 2);

% Estimate velocities
estimatedVelocity       = estimateVelocities(originalDetections, startFrame, endFrame, params.nearestNeighbors, params.speedLimit);

% Spatial groupping
spatialGroupIDs         = getSpatialGroupIDs(dataset.useGrouping, currentDetectionsIDX, detectionCenters, params);

% show window detections
if VISUALIZE
    if dataset.halfFrameRate
        trackletsVisualizePart1_30fps;
    else
        trackletsVisualizePart1;
    end
end

%% SOLVE A GRAPH PARTITIONING PROBLEM FOR EACH SPATIAL GROUP
fprintf('Creating tracklets: solving space-time groups ');
for spatialGroupID = 1 : max(spatialGroupIDs)
    
    elements = find(spatialGroupIDs == spatialGroupID);
    spatialGroupObservations        = currentDetectionsIDX(elements);
    
    % create an appearance affinity matrix and a motion affinity matrix
    appearanceScores                = getAppearanceSubMatrix(spatialGroupObservations, allFeatures, params.distanceType, params.alpha);
    spatialGroupDetectionCenters    = detectionCenters(elements,:);
    spatialGroupDetectionFrames     = detectionFrames(elements,:);
    spatialGroupEstimatedVelocity   = estimatedVelocity(elements,:);
    [motionScores, impMatrix]       = motionAffinity(spatialGroupDetectionCenters,spatialGroupDetectionFrames,spatialGroupEstimatedVelocity,params.speedLimit, params.beta);
    
    % combine affinities into correlations
    correlationMatrix               = motionScores + appearanceScores - 1; 
    correlationMatrix(impMatrix==1) = -inf;
    intervalDistance                = pdist2(spatialGroupDetectionFrames,spatialGroupDetectionFrames);
    discountMatrix                  = min(1, -log(intervalDistance/params.frameInterval));
    correlationMatrix               = correlationMatrix .* discountMatrix;
    
    % show spatial grouping and correlations
    if VISUALIZE
        if dataset.halfFrameRate
            trackletsVisualizePart2_30fps; 
        else
            trackletsVisualizePart2; 
        end
    end
    
    % solve the graph partitioning problem
    fprintf('%d ',spatialGroupID);
    greedySolution = AL_ICM(sparse(correlationMatrix));
    
    if strcmp(dataset.method,'AL-ICM')
        labels = greedySolution;
    elseif strcmp(dataset.method,'BIP')
        labels = solveBIP(correlationMatrix,greedySolution);
    end
    
    labels      = labels + totalLabels;
    totalLabels = max(labels);
    identities  = labels;
    originalDetections(spatialGroupObservations, 1) = identities;
    
    % show clustered detections
    if VISUALIZE
        if dataset.halfFrameRate
            trackletsVisualizePart3_30fps; 
        else
            trackletsVisualizePart3; 
        end
    end
end
fprintf('\n');

%% FINALIZE TRACKLETS
% fit a low degree polynomial to include missing detections and
% smooth the tracklet
trackletsToSmooth  = originalDetections(currentDetectionsIDX,:);
featuresAppearance = allFeatures.appearance(currentDetectionsIDX);
smoothedTracklets  = smoothTracklets(trackletsToSmooth, startFrame, params.frameInterval, featuresAppearance, params.minTrackletLength, currentInterval);

% assign IDs to all tracklets
for i = 1:length(smoothedTracklets)
    smoothedTracklets(i).id = i;
    smoothedTracklets(i).ids = i;
end

% attach new tracklets to the ones already discovered from this batch of
% detections
if ~isempty(smoothedTracklets)
    ids = 1 : length(smoothedTracklets); %#ok
    tracklets = [tracklets, smoothedTracklets];
end

% show generated tracklets in window
if VISUALIZE
    if dataset.halfFrameRate
        trackletsVisualizePart4_30fps; 
    else
        trackletsVisualizePart4; 
    end
end

if ~isempty(tracklets)
    tracklets = nestedSortStruct(tracklets,{'startFrame','endFrame'});
end

