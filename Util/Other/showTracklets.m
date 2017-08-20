myStart = dataset.startingFrame;
myEnd   = dataset.endingFrame;



for k = myStart : 10 : myEnd
    
    frame = k + syncTimeAcrossCameras(dataset.camera);
    image  = readFrame(dataset,frame);
    figure(10);
    clf('reset');
    imshow(image);
    hold on;
    trackletsInWindow = findTrackletsInWindow(tracklets, frame - 100, frame);
    
    currentTracklets    = tracklets(trackletsInWindow);
    numTracklets = length(currentTracklets);
    
    %     trackletCenters = [currentTracklets.center];
    %     plot(trackletCenters(:,1),trackletCenters(:,2));
    %     hold on;
    colors = distinguishable_colors(numTracklets);
    for i = 1 : numTracklets
        
        detections = currentTracklets(i).data;
        trackletCentersView = getBoundingBoxCenters(detections(:,[3:6]));
        %        scatter(trackletCentersView(:,1),trackletCentersView(:,2), '.', 'MarkerFaceColor',colors(i,:));
        plot(trackletCentersView(:,1),trackletCentersView(:,2),'LineWidth',4,'Color',colors(i,:));
        hold on;
        
    end
    
    hold off;
    drawnow;
    
    
end