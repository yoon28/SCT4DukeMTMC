function [featuresAppearance, thisDet ]= loadCurrentFeatures(dataset, allDets, featuresAppearance, segmentRange)
%LOADCURRENTFEATURES compute / load them only only for unseen frames
% newFiles is the number of detection packs that was loaded this loop
% outerRange identifies the last pack retrieved by loadCurrentDetections

fileName = sprintf('appearance_frames_%d_%d.mat', segmentRange(1), segmentRange(end));
if isempty(featuresAppearance), featuresAppearance.appearance = []; featuresAppearance.frames = []; end

if ~dataset.loadAppearance
    % extract features for all frames
    if dataset.halfFrameRate
        thisDet.detections = allDets.detections(ismember(allDets.detections(:, 2), segmentRange+syncTime30fps(dataset.camera)), :); % yoon
        thisDet.partBasedDetections = allDets.partBasedDetections(ismember(allDets.detections(:, 2), segmentRange+syncTime30fps(dataset.camera)), :); % yoon
    else
        thisDet.detections = allDets.detections(ismember(allDets.detections(:, 2), segmentRange+syncTimeAcrossCameras(dataset.camera)), :);
        thisDet.partBasedDetections = allDets.partBasedDetections(ismember(allDets.detections(:, 2), segmentRange+syncTimeAcrossCameras(dataset.camera)), :);
    end
    
    this_featuresAppearance = extractPartBasedFeatures(dataset, thisDet);
%    save(fullfile(dataset.path, 'appearance', sprintf('camera%d', dataset.camera), fileName), 'this_featuresAppearance');
    
    featuresAppearance.appearance   = [featuresAppearance.appearance; this_featuresAppearance.appearance];
    featuresAppearance.frames       = [featuresAppearance.frames, this_featuresAppearance.frames];
else
    % check for file existance
    assert(exist(fullfile(dataset.path, 'appearance', sprintf('camera%d', dataset.camera), fileName), 'file')>0,...
        'Appearance feature file does not exist...');
    
    % load precomputed features
    featuresAppearance_last = load(fullfile(dataset.path, 'appearance', sprintf('camera%d', dataset.camera), fileName));
    featuresAppearance_last = featuresAppearance_last.this_featuresAppearance;
    
    % eventually append to previous features if in the middle of 2
    % windows
    featuresAppearance.appearance   = [featuresAppearance.appearance;   featuresAppearance_last.appearance];
    featuresAppearance.frames       = [featuresAppearance.frames,       featuresAppearance_last.frames];
    
    thisDet = allDets; % added by yoon 
end

end