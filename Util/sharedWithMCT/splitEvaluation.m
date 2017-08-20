function out = splitEvaluation(varargin)
%% INPUT VARIABLES PARSING
% VARARGIN{1} - dataset
% VARARGIN{2} - number of total splits
% VARARGIN{3} - split to select for evaluation
groundTruthFile      = varargin{1};
trajectoriesFile     = varargin{2};
camera      = str2num(varargin{3}); %#ok
startLimit  = str2num(varargin{4}); %#ok
endLimit    = str2num(varargin{5}); %#ok
nSplits     = str2num(varargin{6}); %#ok
splitK      = str2num(varargin{7}); %#ok

% path to tracker output file and GT
groundTruth = dlmread(groundTruthFile, ' ');
trackerData = dlmread(trajectoriesFile, ' ');

%% RESTRICT GROUNDTRUTH E TRACKER DATA TO EVALUATION RANGE
groundTruth = groundTruth(groundTruth(:, 2) >= startLimit...
                        & groundTruth(:, 2) <= endLimit, :);

trackerData = trackerData(trackerData(:, 2) >= startLimit...
                        & trackerData(:, 2) <= endLimit, :);

%% PREPARE DATA FOR EVALUATION
groundTruth = sortrows(groundTruth, [2,1]);
trackerData = sortrows(trackerData(:, 1:6), [2,1]);

% convert data into the MOTchallenge format
temp = groundTruth(:, 1); groundTruth(:, 1) = groundTruth(:, 2); groundTruth(:, 2) = temp;
temp = trackerData(:, 1); trackerData(:, 1) = trackerData(:, 2); trackerData(:, 2) = temp;

% split data
myFrames = startLimit : endLimit;
mySize   = length(myFrames);

res      = mod(mySize, nSplits);
quot     = floor(mySize / nSplits);

% select current frames
if splitK < nSplits
    y        = reshape(myFrames(1:end-quot-res), quot, nSplits-1);
    thisFrames = y(:, splitK);
else
    thisFrames = myFrames(max(1, end-quot-res+1):end);
end

% select submatrix
groundTruth = groundTruth(ismember(groundTruth(:, 1), thisFrames), :);
trackerData = trackerData(ismember(trackerData(:, 1), thisFrames), :);

% put base to frame 1
minFrame = min([groundTruth(:, 1); trackerData(:, 1)]);
groundTruth(:, 1) = groundTruth(:, 1) - minFrame + 1;
trackerData(:, 1) = trackerData(:, 1) - minFrame + 1;

%% EVALUATION
allMets = evaluateTracking(sprintf('camera%d', camera), groundTruth, trackerData);
%printMetrics(allMets.mets2d.m);

out.startLimit  = thisFrames(1);
out.endLimit    = thisFrames(end);
out.camera      = camera;
out.results     = allMets.mets2d.m;

end