function spatialGroupIDs = getSpatialGroupIDs(useGrouping, currentDetectionsIDX, detectionCenters, params )
% Perfroms spatial groupping of detections and returns a vector of IDs

spatialGroupIDs         = ones(length(currentDetectionsIDX), 1);
if useGrouping == true
    pairwiseDistances   = pdist2(detectionCenters, detectionCenters);
    agglomeration       = linkage(pairwiseDistances);
    numSpatialGroups    = round(params.clusterCoeff * length(currentDetectionsIDX) / params.frameInterval);
    numSpatialGroups    = max(numSpatialGroups, 1);
    spatialGroupIDs     = cluster(agglomeration, 'maxclust', numSpatialGroups);
end



