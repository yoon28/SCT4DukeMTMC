function trajectoriesInWindow = findTrajectoriesInWindow(trajectories, startTime, endTime)
trajectoriesInWindow = [];

if isempty(trajectories), return; end

trajectoryStartFrame = cell2mat({trajectories.startFrame});
trajectoryEndFrame   = cell2mat({trajectories.endFrame});
trajectoriesInWindow  = find( (trajectoryEndFrame >= startTime) .* (trajectoryStartFrame <= endTime) );

