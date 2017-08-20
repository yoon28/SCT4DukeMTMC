function [allDets] = loadCurrentDetections(dataset)
%LOADCURRENTDETECTIONS load detections from file according to frameRange
%   The method also consider possible camera frame shifts due to
%   unsynchronized timestamps throuogh the use of dataset. If all frames in
%   frameRange are already considered in currentDetections, then it just
%   return currentDetections.

% we need to attach new data by loading a file
allDets.currentDetections   = [];
allDets.detections          = [];
allDets.partBasedDetections = [];

temp = load(fullfile(dataset.path, 'detections', sprintf('camera%d.mat', dataset.camera)), 'detections');
temp.detections = temp.detections(temp.detections(:, 2) >= (dataset.startingFrame+syncTimeAcrossCameras(dataset.camera)) & temp.detections(:, 2) <= (dataset.endingFrame+syncTimeAcrossCameras(dataset.camera)), :);
[temp_det, temp_part]       = parseDetections2(dataset, temp.detections);
allDets.detections          = temp_det;
allDets.partBasedDetections = temp_part;
allDets.currentDetections   = temp.detections;

end

