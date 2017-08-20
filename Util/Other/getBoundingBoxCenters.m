function [ centers ] = getBoundingBoxCenters( boundingBoxes )
% Returns the centers of the bounding boxes provided in the format:
% left, top, right, botom

centers = [ boundingBoxes(:,1) + boundingBoxes(:,3), boundingBoxes(:,2) + boundingBoxes(:,4)];
centers = 0.5 * centers;



