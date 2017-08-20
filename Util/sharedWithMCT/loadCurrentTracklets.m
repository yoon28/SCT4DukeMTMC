function [tracklets, lastEndLoaded] = loadCurrentTracklets(dataset, tracklets, startTime, endTime, lastEndLoaded)

% convert startFrame and endFrame to the synchronized time
startTime  = startTime    + syncTimeAcrossCameras(dataset.camera);
endTime    = endTime      + syncTimeAcrossCameras(dataset.camera);

% check if we need to load more tracklets
if endTime > lastEndLoaded
    % otherwise we need to attach new data by loading a new file
    fileList = dir(dataset.trackletsDir); fileList = fileList(3:end);
  
    for i = 1 : length(fileList)
        C = strsplit(fileList(i).name, '_');
        ranges(1) = str2double(C{5});
        ranges(2) = str2double(C{6}(1:end-4));
        
        if endTime > ranges(1) && startTime < ranges(2)
            temp = load(fullfile(dataset.trackletsDir, fileList(i).name));
            if size(tracklets, 1) > 1, tracklets = tracklets'; end
            tracklets = [tracklets, temp.tracklets]; %#ok
            lastEndLoaded = ranges(2);
        end
    end
end


end