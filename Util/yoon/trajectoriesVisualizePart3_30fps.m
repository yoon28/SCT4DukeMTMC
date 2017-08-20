%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VISUALIZE 3: SHOW ALL MERGED TRACKLETS IN WINDOWS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure, imshow(readFrame30to60(dataset,min(endTime, dataset.endingFrame+syncTime30fps(dataset.camera)) )); % yoon
hold on;

currentTrajectories = smoothTrajectories;
numTrajectories = length(currentTrajectories);

colors = distinguishable_colors(numTrajectories);
for k = 1:numTrajectories
    
    
    for i = 1 : length(currentTrajectories(k).tracklets)
        
        detections = currentTrajectories(k).tracklets(i).data;
        trackletCentersView = getBoundingBoxCenters(detections(:, 3:6));
        
        plot(trackletCentersView(:,1),trackletCentersView(:,2),'LineWidth',4,'Color',colors(k,:));
        hold on;
        
    end
    
end

hold off;
drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
