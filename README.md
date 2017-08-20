# SCT4DukeMTMC

## Intro

This is the Single Camera Tracker(SCT)[1,2] for DukeMTMC dataset[1].

You can download the DukeMTMC dataset from [here](http://vision.cs.duke.edu/DukeMTMC/).

This program is modification of original [SCT software](http://vision.cs.duke.edu/DukeMTMC/data/demo_code/SCT.zip) that can only process one camera(camera no.2) among eight cameras in Duke campus within a specific range of time.

What this code can do is

- can process all cameras in DukeMTMC dataset for any given range of time.
- can produce tracking results comparable to the original report[1,2].

To process all cameras, you can run `DoAllDukeCams.m` then they will be processed sequentially. Otherly, you can run multiple Matlab and run them seperately by writing your own scripts.

To reproduce the results, I have consulted with [Ergys Ristani](mailto:ristani@cs.duke.edu) and [Francesco Solera](mailto:francesco.solera@unimore.it). They told me that they actually did the experiment with 30 fps setting instead of 60 fps which is basic framerate of DukeMTMC. That's why you can see the variable, `halfFrameRate` in configuration file for each camera, that controls the framerate. Furthermore, they also recommend to filter out the false positive detections by using masks provided in DukeMTMC dataset. You can check that code in the file named `Util/Other/filterDetections.m` between line number 84 and 110. Moreover, I left comments on the code, `% yoon`, where I made the modification.

After I investigated the results with Trainval_Mini dataset, which is some portion of Trainval dataset, removing false positive detections using masks is crucial to reproduce the results but changing the framerate is not critical. You can check that fact using this code. Note that I only investigated it using Trainval_Mini, so it might be different if you check it with other partitions of dataset.

## Usage

The first step of using this code is downloding the DukeMTMC dataset. You can download it from [here](http://vision.cs.duke.edu/DukeMTMC/). Then, locate the dataset directory you downloaded in `config.m`. It is recommened to use Gurobi solver in order to get good results.

There are configuration files named `camera<camnum>_exp.config`, where `<camnum>` is camera number. In there, you can set start and end time by manipulating `startingFrame` and `endingFrame` respectively. Note that you have to insert time synced to master camera(camera no.5).

The variable `fpRemoval`, which is in configuration files, is the threshold to remove false positive detections using masks. It will remove detections if (num of white pixels in the mask)/(area of detection b-box) < fpRemoval. It might be somewhat related to moving speed of detected object.

To process with 30 fps dataset, you need to set `halfFrameRate = 1` in configuration files. Besides, you have to make 30 fps detection data using the scrip `det60to30.m`, which is located in `Util/yoon/`. The script samples even numbered frames from original data and save the generated detection data with new files `your/data/location/det30/camera<camnum>_30.mat`.

## Reference

[1] Performance Measures and a Data Set for Multi-Target, Multi-Camera Tracking. E. Ristani, F. Solera, R. S. Zou, R. Cucchiara and C. Tomasi. ECCV 2016 Workshop on Benchmarking Multi-Target Tracking.

[2] Tracking Multiple People Online and in Real Time. E. Ristani and C. Tomasi. ACCV 2014.
