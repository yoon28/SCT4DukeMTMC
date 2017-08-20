global dataset;
dataset = [];

% Dependency configuration
gurobiPath      = '/opt/gurobi/gurobi751/linux64/matlab/'; % set your gurobi path
ffmpegPath      = '/usr/bin/ffmpeg';
dataset.path    = '/storage2/datasets/DukeMTMC/'; % local directory where the dataset is located

% data set parameters (no need to change below this point)
dataset.framesFormat = '%07d.jpg'; % set your image file type
dataset.imageWidth = 1920;
dataset.imageHeight = 1080;