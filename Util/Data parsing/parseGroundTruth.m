function [ groundTruth ] = parseGroundTruth( dataset )
% Parses the ground truth of a given dataset
%
% Ground truth should be provided in the following format:
% personNumber, frameNumber, bodyLeft, bodyTop, bodyRight, bodyBottom

groundTruth = csvread(dataset.groundTruth);

% Keep frames for which we have ground truth
timeFilter = groundTruth(:,2)<=dataset.numberOfFrames;

% Keep only detections within the frame borders
frameFilter = (groundTruth(:,3)>=1) .* (groundTruth(:,4)>=1) ...
    .* (groundTruth(:,5)<=dataset.imageWidth).* (groundTruth(:,6)<=dataset.imageHeight);

% Keep relevant ground truth
filter = logical( frameFilter .* timeFilter );
groundTruth = groundTruth(filter,:);

% Sort by identities, then by frames
groundTruth  = sortrows(groundTruth,[2 1]);

% Use camera transformation if applicable
if dataset.world

    projectiveTransformation = fitgeotrans(dataset.movingPoints, dataset.fixedPoints, 'Projective');

    % Add world coordinates
    feetPositionGT = [ 0.5*(groundTruth(:,5) + groundTruth(:,3)), groundTruth(:,6) ];
    worldcoordsGT = transformPointsForward(projectiveTransformation, feetPositionGT)/100;
    groundTruth = [ groundTruth, worldcoordsGT ];
    
end
    
    