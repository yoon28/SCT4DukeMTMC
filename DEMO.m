% clear; 
% close all; 
% config; 
% setup;
% 
% %% LOAD SETTINGS
% configFile   = 'camera2_exp.config';
% dataset      = loadExperimentSetting(configFile, dataset);

VISUALIZE    = false;

%% check time
NUM_OF_FRAMES = [359580, 360720, 355380, 374850, 366390, 344400, 337680, 353220]; % the total number of frames for each DukeMTMC camera.
if dataset.startingFrame + syncTimeAcrossCameras(dataset.camera) < 1 % || dataset.endingFrame + syncTimeAcrossCameras(dataset.camera) > NUM_OF_FRAMES(dataset.camera) %% 7번 마지막 프레임 남음
    error('TIME ERROR'); % the processing time was set wrongly.
end

%% transform the processing time from 60 fps to 30 fps
if dataset.halfFrameRate
    dataset = dataset60to30(dataset); % yoon
end

%% CREATE TRACKLETS
% parse detections
if dataset.halfFrameRate
    allDets = loadCurrentDetections30fps(dataset); % yoon
else
    allDets = loadCurrentDetections(dataset); 
end

% initialize variables
featuresAppearance  = []; 
tracklets = struct([]);

for startFrame   = dataset.startingFrame : dataset.tracklets.frameInterval : dataset.endingFrame
    % print loop state
    fprintf('%d/%d\n', startFrame, dataset.endingFrame);
    endFrame     = startFrame + dataset.tracklets.frameInterval - 1;
    segmentRange = startFrame : endFrame;
    
    % extract appearance features
    [featuresAppearance, thisDets]         = loadCurrentFeatures(dataset, allDets, featuresAppearance, segmentRange);
    [filteredDetections, filteredFeatures] = filterDetections(dataset, thisDets, featuresAppearance);
    
    % compute actual tracklets
    tracklets                              = createTracklets(dataset, filteredDetections, filteredFeatures, startFrame, endFrame, tracklets, VISUALIZE);
end

%% CREATE TRAJECTORIES
lastEndLoaded       = 0;

% initialize range
startTime = dataset.startingFrame - dataset.trajectories.windowWidth + 1;
endTime   = dataset.startingFrame + dataset.trajectories.windowWidth - 1;

trajectories = trackletsToTrajectories(tracklets,1:length(tracklets));

while startTime <= dataset.endingFrame
    % print loop state
    % clc; 
    close all;
    fprintf('Window %d...%d\n', startTime, endTime);
    
    % attach tracklets and store trajectories as they finish
    trajectories = createTrajectories( dataset, trajectories, startTime, endTime, VISUALIZE);
    
    % update loop range
    startTime = endTime   - dataset.trajectories.overlap;
    endTime   = startTime + dataset.trajectories.windowWidth;
end

% save trajectories
trackerOutput = trajectoriesToTop(trajectories);

%% 30 fps to 60 fps % yoon 
if dataset.halfFrameRate
    dataset = dataset30to60(dataset);
    myOutput = myOutputGen30to60(dataset, trackerOutput);
else
    myOutput = myOutputGen(dataset, trackerOutput);
end

if exist('results','dir') == 0
    mkdir('results');
end
fname = sprintf('results/cam%d_%07d_%07d.txt',[dataset.camera, dataset.startingFrame, dataset.endingFrame]);
dlmwrite(fname, myOutput, 'delimiter', ' ', 'precision', 6);

rmpath(genpath('Core'));
rmpath(genpath('Util'));

%% PREVIEW
% addpath(genpath('Util'));
% if dataset.halfFrameRate
%     trackerOutput(:, 2) = trackerOutput(:, 2) - syncTime30fps(dataset.camera); % yoon
%     previewResults30fps(dataset, trackerOutput);
% else
%     trackerOutput(:, 2) = trackerOutput(:, 2) - syncTimeAcrossCameras(dataset.camera);
%     previewResults(dataset, trackerOutput);
% end
% rmpath(genpath('Util'));
