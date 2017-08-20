function [features] = extractPartBasedFeatures(dataset, allDets)
% This function computes HSV histograms for all detections and all parts
% of each detection

% parse input
partBasedDetections     = allDets.partBasedDetections;
detections              = allDets.detections;

features.appearance = cell(size(detections, 1), 1);

count = 1;
for frame = unique(detections(:, 2))'
    
    % clc
    fprintf('Computing appearance features, this might take a while...\n');
    if dataset.halfFrameRate
        fprintf('%d/%d\n', frame-syncTime30fps(dataset.camera), max(detections(:, 2))-syncTime30fps(dataset.camera));
    else
        fprintf('%d/%d\n', frame-syncTimeAcrossCameras(dataset.camera), max(detections(:, 2))-syncTimeAcrossCameras(dataset.camera));
    end
    
    rows = find(detections(:,2) == frame);
    
    if dataset.halfFrameRate
        image = readFrame30to60(dataset, frame); % yoon
    else
        image = readFrame(dataset, frame);
    end
%     figure(1); clf; imshow(image); hold on;
    
    if isempty(rows)
        continue;
    end
     
    partBasedDetectionsFrame = int32(partBasedDetections(rows,:));
    height = dataset.imageHeight;
    width = dataset.imageWidth;
    
    maxIndex = size(partBasedDetectionsFrame,2) - 2;
    
    left = max(1,partBasedDetectionsFrame(:,9:4:maxIndex));
    top = max(1,partBasedDetectionsFrame(:,10:4:maxIndex));
    right = min(width,partBasedDetectionsFrame(:,11:4:maxIndex));
    bottom = min(height,partBasedDetectionsFrame(:,12:4:maxIndex));
    
    for k = 1 : size(left,1)
        
        feature = [];
%         rectangle('Position',[detections(rows(k),3), detections(rows(k),4), detections(rows(k),5)-detections(rows(k),3), detections(rows(k),6)-detections(rows(k),4) ], 'EdgeColor', 'g'); % yoon
        
        for i = 1 : size(left,2)
            
            y1 = min(top(k,i),height);
            y2 = max(bottom(k,i),1);
            x1 = min(left(k,i),width);
            x2 = max(right(k,i),1);
            
%             rectangle('Position', [x1, y1, x2-x1, y2-y1]);
            
            histogram = extractHSVHistogram(image(y1:y2,x1:x2,:));
            feature = [feature, histogram];
            
        end
        
        features.appearance{count}  = feature;
        features.frames(count)       = frame;
        count = count + 1;
    end
    
%     pause
end


