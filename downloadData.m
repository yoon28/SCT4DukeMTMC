clear; config;
fprintf('Patience, this may take minutes (~400Mb)!\n');

mkdir(dataset.path);
fprintf('Downloading detections, frames and precomputed appearance features...\n');
url = sprintf('http://vision.cs.duke.edu/DukeMTMC/data/demo_data/Data.zip');
websave(fullfile(dataset.path, 'Data.zip'), url);
fprintf('Unzipping folder structure...\n');
unzip(fullfile(dataset.path, 'Data.zip'), dataset.path)




