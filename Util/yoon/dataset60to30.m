function dataset = dataset60to30(dataset)

startFrame = dataset.startingFrame;
endFrame = dataset.endingFrame;

dataset.startingFrame_temp = dataset.startingFrame;
dataset.endingFrame_temp = dataset.endingFrame;

startFrame = round(startFrame/2);
endFrame = round(endFrame/2);

dataset.startingFrame = startFrame;
dataset.endingFrame = endFrame;
