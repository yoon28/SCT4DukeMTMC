function [ dataset ] = loadDataset( name )
% Returns the corresponding dataset parameters. 

dataset = [];
dataset.tracklets = [];
dataset.trajectories = [];

dataset.baseName = 'dukeChapel';

switch name
    
    case 'camera1'
        
        dataset.name = 'camera1';
        dataset.path = fullfile('..', dataset.baseName, dataset.name);
        dataset.framesDirectory = fullfile(dataset.path, 'frames');
        dataset.detectionsDir = fullfile(dataset.path, 'detections');
        dataset.groundTruthDir = fullfile(dataset.path, 'groundtruth.txt');
        dataset.appearanceFeatures = fullfile(dataset.path, 'featuresAppearance.mat');
        
        dataset.numberOfFrames = 4500;
        dataset.frameRate = 25;
        dataset.imageWidth = 1920;
        dataset.imageHeight = 1080;
        dataset.maxPedestrianHeight = 330; % pixels
        dataset.minTargetDistance = 0.5; % meters
        dataset.world = true; % evaluate in world coordinates
        dataset.fixedPoints = [0,0;500,0;500,500;0,500]; % image to plane transformation
        dataset.movingPoints = [1116,219;1527,266;1307,481;820,398];
        dataset.nonROI{1} = [0,490;520,268;499,0;0,0];
        dataset.minimumTrajectoryDuration = 50; % frames
        
        dataset.tracklets.frameInterval = 25;
        dataset.tracklets.alpha = 1;
        dataset.tracklets.beta = 1;
        dataset.tracklets.lambda = 6;
        dataset.tracklets.mu = 0.25;
        dataset.tracklets.clusterCoeff = 1;
        dataset.tracklets.nearestNeighbors = 8;
        dataset.tracklets.speedLimit = 0.4;
        dataset.tracklets.distanceType = 'histogram_intersection';
        dataset.tracklets.minTrackletLength = 0.4* dataset.tracklets.frameInterval;

        dataset.trajectories.appearanceGroups = 5;
        dataset.trajectories.alpha = 1;
        dataset.trajectories.beta = 0.2;
        dataset.trajectories.lambda = 6;
        dataset.trajectories.mu = 0.15;
        dataset.trajectories.windowWidth = 300;
        dataset.trajectories.overlap = 150;
        dataset.trajectories.speedLimit = 0.4;
        dataset.trajectories.distanceType = 'histogram_intersection';
        dataset.trajectories.indifferenceTime = 200;
        
        
end