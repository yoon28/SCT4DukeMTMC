function [ frame ] = readMask60( dataset, i )
% This functions reads the i-th frame of the dataset

frame = imread(fullfile(dataset.path, 'masks', sprintf('camera%d/%d.png', dataset.camera, i)));
