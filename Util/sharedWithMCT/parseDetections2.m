function [detections, partBasedDetections] = parseDetections2(dataset, newSetOfDetections)

% divide detection data in whole BB and parts for feature computations
partBasedDetections = newSetOfDetections(:, 3:end);
detections          = newSetOfDetections(:, 1:6);

% use camera transformation if applicable
if dataset.world
    
    feetPosition = [0.5*(detections(:,5) + detections(:,3)), detections(:,6)];
    
    % check if we are running on the stairs of camera 2
    stairs_idx = zeros(size(feetPosition, 1), 1);
    addToDetections = zeros(size(feetPosition, 1), 2);
    if      dataset.camera == 2 && ...
            any(inpolygon(feetPosition(:,1), feetPosition(:,2), dataset.stairsPolygon(:,1), dataset.stairsPolygon(:,2)))
        
        % find the detections on the stairs
        stairs_idx = inpolygon(feetPosition(:,1), feetPosition(:,2), dataset.stairsPolygon(:,1), dataset.stairsPolygon(:,2));
        
        % in this case simply compute the homography with the information
        % about the stairs
        H_stairs = findHomography(dataset.imagePointsStairs', dataset.worldPointsStairs');
        worldcoords = H_stairs*[feetPosition(stairs_idx, :) ones(size(feetPosition(stairs_idx, :), 1), 1)]';
        worldcoords = worldcoords(1:2, :) ./ repmat(worldcoords(3, :), 2, 1);
        addToDetections(stairs_idx, :) = worldcoords';
    end
    
    H = findHomography(dataset.imagePoints', dataset.worldPoints');
    worldcoords = H*[feetPosition(~stairs_idx, :) ones(size(feetPosition(~stairs_idx, :), 1), 1)]';
    worldcoords = worldcoords(1:2, :) ./ repmat(worldcoords(3, :), 2, 1);
    addToDetections(~stairs_idx, :) = worldcoords';
    detections = [detections, addToDetections];
    
    % figure(5)
    % scatter(addToDetections(~stairs_idx, 1), addToDetections(~stairs_idx, 2), 10, 'r', 'filled');
    % hold on;
    % scatter(addToDetections( stairs_idx, 1), addToDetections( stairs_idx, 2), 10, 'b', 'filled');
    % hold off;
    % pause
    
else
    
    % use body centers as coordinates
    bodyCenters = getBoundingBoxCenters(detections(:,3:6));
    detections = [detections, bodyCenters];
end





