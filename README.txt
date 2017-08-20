Demo code for Singe Camera Tracker

To run the code you need to:
    1) install gurobi (free with academic licence, 5 min)
    2) edit paths on lines 5-7 in config.m (2 min)
    3) run downloadData.m to get all the required data to run the tracker demo (2 min)
    3) run DEMO.m!

Notes:
- When you set the path on line 7 in config.m, consider a few MB of data will be downloaded (images, detections and precomputed appearances).
- You can see what the tracker is doing on the inside by setting the flag VISUALIZE to true on line 9 in DEMO.m
- Tracker parameters can be changed (but should not need to) in camera2_exp.config.
- This demo will run on a very short subsequence of a much larger and nicer dataset. You can download it from: http://vision.cs.duke.edu/DukeMTMC/

