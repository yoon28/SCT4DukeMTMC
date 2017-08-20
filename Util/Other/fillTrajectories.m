function [ detectionsUpdated ] = fillTrajectories( detections )
% This function adds points by interpolation to the resulting trajectories

detections = sortrows(detections,[2 3 4 5 6]);
detections(:,1) = 0;
detectionsUpdated = [];

personIDs = unique(detections(:,1));

count = 0;

for i = 1 : length(personIDs)
   
    personID = personIDs( i );
    
    relevantDetections = detections( detections(:,1) == personID, : );
    
    startFrame = min( relevantDetections(:,2));
    endFrame = max( relevantDetections(:,2) );
    
    missingFrames = setdiff( [startFrame:endFrame]', relevantDetections(:,2) );
    
    if isempty(missingFrames)
        
        continue;
        
    end
    
    frameDiff = diff(missingFrames') > 1;
    
    startInd = [1, frameDiff];
    endInd = [frameDiff, 1];
    
    startInd = find(startInd);
    endInd = find(endInd);
    
    trajectoryData = zeros(length(startFrame:endFrame),size(detections,2));
    trajectoryData(:,2) = startFrame:endFrame;
    
    trajectoryData( ismember(trajectoryData(:,2),relevantDetections(:,2)),:) = relevantDetections( ismember(relevantDetections(:,2),trajectoryData(:,2)),:);
  
    
    for k = 1:length(startInd)
       
        interpolatedDetections = zeros( missingFrames(endInd(k)) - missingFrames(startInd(k)) + 1 , size(detections,2) );
        
        interpolatedDetections(:,1) = personID;
        interpolatedDetections(:,2) = [ missingFrames(startInd(k)):missingFrames(endInd(k)) ]';
        
        preDetection = detections( (detections(:,1) == personID) .* detections(:,2) == missingFrames(startInd(k)) - 1, :);
        postDetection = detections( (detections(:,1) == personID) .* detections(:,2) == missingFrames(endInd(k)) + 1, :);
        
        for c = 3:size(detections,2)
           
            interpolatedDetections(:,c) = linspace(preDetection(c),postDetection(c),size(interpolatedDetections,1));
            
        end
        
        trajectoryData( ismember(trajectoryData(:,2),missingFrames(startInd(k)):missingFrames(endInd(k))),:) = interpolatedDetections;
        
%         interpolatedDetections = [preDetection; interpolatedDetections; postDetection];
        
%        
        
    end
    
    detectionsUpdated = [ detectionsUpdated; trajectoryData ];
    
    count = count + length( missingFrames );
 
end







