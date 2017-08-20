function [detections, partBasedDetectionsMat] = parseDetections(dataset, frameRange)
% Reads the input part-based person detections

% understand which files we need to load from dataset.detectionsDir

% Read detections from each frame
partBasedDetections = partBasedDetections.detections;
numDetections = 0;
for frame = 1 : dataset.numberOfFrames
    numDetections = numDetections + size(partBasedDetections{frame},1);
end
    
detections = zeros(numDetections,6);
partBasedDetectionsMat = zeros(numDetections,size(partBasedDetections{1},2));

count = 1;
for frame = 1 : dataset.numberOfFrames
    fprintf('Parsing detections at frame %d\n', frame);
    if isempty(partBasedDetections{frame})
        continue;
    end
    
    numDetections = size(partBasedDetections{frame},1);
    vones = ones(numDetections,1);
    detections(count:count+numDetections-1,:) = [ vones, vones*frame, partBasedDetections{frame}(:,1:4) ];
    
    partBasedDetectionsMat(count:count+numDetections-1,:) = [partBasedDetections{frame}];
    count = count + numDetections;
    
end

% Keep only detections of acceptable height
heightFilter = abs( detections(:,4)-detections(:,6) ) <= dataset.maxPedestrianHeight;

% Keep only detections up to the maximum frame
timeFilter = detections(:,2)<= dataset.numberOfFrames;

% Keep only detections within the image 
frameFilter = (detections(:,3)>1) .* (detections(:,4)>1) ...
    .* (detections(:,5)<=dataset.imageWidth).* (detections(:,6)<=dataset.imageHeight);

% Discard big detections containing other detections 
boxSizeFilter = [];

for frame = 1 : length(partBasedDetections)
    
    frameDetections = detections(detections(:,2)==frame,:);
    currentBoxFilter = ones(size(frameDetections,1),1);
    
    rect = int32([ frameDetections(:,3), frameDetections(:,4), frameDetections(:,5) - frameDetections(:,3), frameDetections(:,6) - frameDetections(:,4) ]);
    areas = repmat(rect(:,3).*rect(:,4),1,size(rect,1));
    intersectionAreas = rectint(rect,rect);
    diff = intersectionAreas == areas;
    diff2 = double(intersectionAreas)./double(areas);
    diff(1:size(frameDetections,1)+1:end) = 0;
    diff2(1:size(frameDetections,1)+1:end) = 0;
    
    [r c] = find(diff2>0.5);
    
    if ~isempty(r)
        currentBoxFilter(c) = 0;
    end
    
    boxSizeFilter = [boxSizeFilter; currentBoxFilter];
    
end

filter = find(heightFilter .* timeFilter .* boxSizeFilter .*frameFilter);

detections = detections(filter,:);
partBasedDetectionsMat = partBasedDetectionsMat(filter,:);

% Use camera transformation if applicable

if dataset.world
    
    projectiveTransformation = fitgeotrans(dataset.movingPoints, dataset.fixedPoints, 'Projective');
    
    % Add world coordinates
    feetPosition = [ 0.5*(detections(:,5) + detections(:,3)), detections(:,6) ];
    worldcoords = transformPointsForward(projectiveTransformation, feetPosition)/100;
    detections = [detections, worldcoords];
    
else
    
    % Use body centers as coordinates
    bodyCenters = getBoundingBoxCenters(detections(:,[3:6]));
    detections = [detections, bodyCenters];
end





