function [ frame ] = readMask30to60( dataset, i )
% This functions reads the i-th frame of the dataset

i2 = i*2;
frame = imread(fullfile(dataset.path, 'masks', sprintf('camera%d/%d.png', dataset.camera, i2)));
