function [ frame ] = readFrame( dataset, i )
% This functions reads the i-th frame of the dataset

frame = imread(fullfile(dataset.path, 'frames', sprintf(['camera%d/' dataset.framesFormat], dataset.camera, i)));
