function [ filteredDetections, filteredFeatures ] = filterDetections( dataset, allDet, features)
% This function filters detections too close to each other by keeping only
% one of them and discards detections which are too large or outside the ROI.

% parse input
detections          = allDet.detections;
partBasedDetections = allDet.partBasedDetections;
filterDistance      = dataset.minTargetDistance;
maxHeight           = dataset.maxPedestrianHeight;

% allocate some variables
startFrame          = min(detections(:,2));
endFrame            = max(detections(:,2));
distanceFilter      = ones(size(detections,1),1);
ROIFilter        = ones(size(detections,1),1); % name changed by yoon

%% REMOVE DETECTIONS THAT DO NOT REACH A SPECIFIC CONFIDENCE
confidenceFilter    = partBasedDetections(:, end) > dataset.confidenceThresh;

%% REMOVE DETECTIONS OUT OF THE IMAGE BOUNDARIES
frameFilter = (detections(:, 3) > 1) ...
            & (detections(:, 4) > 1) ...
            & (detections(:, 5) <= dataset.imageWidth) ...
            & (detections(:, 6) <= dataset.imageHeight);

%% REMOVE DETECTIONS THAT ARE TOO BIG
heightFilter         = abs(detections(:,4) - detections(:,6))  <= maxHeight;

%% REMOVE DETECTIONS THAT ARE OUT OF ROI
feetPosition = [0.5*(detections(:,5) + detections(:,3)), detections(:,6)];

% ROI is specified in pixels
if isfield(dataset, 'ROI_INFO')
    ROIFilter = ROIFilter .* inpolygon(feetPosition(:,1), feetPosition(:,2), dataset.ROI_INFO(:,1), dataset.ROI_INFO(:,2));
end

%% REMOVE DETECTIONS TOO BIG CONTAINING OTHER DETECTIONS
boxSizeFilter = [];
for frame = startFrame : endFrame %unique(detections(:, 2))'
    
    frameDetections = detections(detections(:, 2) == frame,:);
    currentBoxFilter = ones(size(frameDetections, 1), 1);
    
    rect = int32([frameDetections(:,3), frameDetections(:,4), frameDetections(:,5) - frameDetections(:,3), frameDetections(:,6) - frameDetections(:,4)]);
    areas = repmat(rect(:,3).*rect(:,4),1,size(rect,1));
    intersectionAreas = rectint(rect,rect);
    diff2 = double(intersectionAreas)./double(areas);
    diff2(1:size(frameDetections,1)+1:end) = 0;
    
    [r, c] = find(diff2>0.5);
    
    if ~isempty(r)
        currentBoxFilter(c) = 0;
    end
    
    boxSizeFilter = [boxSizeFilter; currentBoxFilter]; %#ok
    
end

%% REMOVE DETECTIONS TOO CLOSE TO EACH OTHERS
for i = startFrame : endFrame
    % select current frame detections
    thisFrame           = detections(:,2) == i;
    currentRows         = find(thisFrame);
    det                 = detections(thisFrame,:);
    
    % compute detections pairwise distances
    detectionCenters    = det(:,[7,8]);
    pairwiseDistances   = pdist2(detectionCenters,detectionCenters);
    
    % find detections too close to each others and delete them
    nearbyPoints        = (pairwiseDistances < filterDistance) ...
        & (pairwiseDistances > 0);
    [row, ~, ~]         = find(nearbyPoints);
    
    if ~isempty(row)
        % keep only first row, filter out the rest (arbitrary)
        rows = unique(row);
        rowsToRemove = rows(2:end);
        distanceFilter(currentRows(rowsToRemove)) = 0;
    end
end

%% APPLY MASK TO FILTER OUT THE DETECTIONS %% written by yoon
maskFilter = ones(size(detections,1),1);
for i = startFrame : endFrame
    thisRows = find( detections(:,2) == i );
    if isempty(thisRows)
        continue;
    end
    
    if dataset.halfFrameRate
        mask = readMask30to60(dataset,i);
    else
        mask = readMask60(dataset,i);
    end
    
    ratio_th = dataset.fpRemoval; % 0.1;
    for j = 1 : length(thisRows)
        det = detections( thisRows(j) , : );   
        msk = mask( int32(max(det(4),1)):int32(min(det(6),dataset.imageHeight)) , int32(max(det(3),1)):int32(min(det(5),dataset.imageWidth)) );
        ratio = sum(msk(:) == 255)/(size(msk,1)*size(msk,2));
        if ratio < ratio_th
            maskFilter( thisRows(j) ) = 0;
        end
    end    
end

%% APPLY FILTERS AND OUTPUT RESULTS
filter = logical(confidenceFilter .* frameFilter .* heightFilter .* ROIFilter .* boxSizeFilter .* distanceFilter .* maskFilter); % apply mask filter %% yoon
filter_ = filter(ismember(detections(:, 2), features.frames));
filter__ = filter .* ismember(detections(:, 2), features.frames) == 1;

filteredDetections          = [detections(filter__,:) partBasedDetections(filter__,:)];
filteredFeatures.appearance = features.appearance(filter_,:);
filteredDetections(:, 1)    = (1:size(filteredDetections,1))';
