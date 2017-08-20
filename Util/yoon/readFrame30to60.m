function [ frame ] = readFrame30to60( dataset, i )
% This functions reads the i-th frame of the dataset

i2 = i*2;
frame = imread(fullfile(dataset.path, 'frames', sprintf(['camera%d/' dataset.framesFormat], dataset.camera, i2)));
