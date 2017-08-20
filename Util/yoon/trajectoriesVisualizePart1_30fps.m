%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VISUALIZE 1: SHOW ALL TRACKLETS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

backgroundImage =  imfuse(readFrame30to60(dataset, max(1,startTime)),readFrame30to60(dataset,min(endTime,dataset.endingFrame+syncTimeAcrossCameras(dataset.camera))),'blend','Scaling','joint'); % yoon
imshow(backgroundImage);
hold on;

trCount = 0;
for k = 1 : length(currentTrajectories)
    
    for i = 1:length(currentTrajectories(k).tracklets)
        trCount = trCount +1;
        detections = currentTrajectories(k).tracklets(i).data;
        trackletCentersView = getBoundingBoxCenters(detections(:,[3:6]));
        scatter(trackletCentersView(:,1),trackletCentersView(:,2),'filled');
        total = size(trackletCentersView,1);
        text(trackletCentersView(round(total/2),1),trackletCentersView(round(total/2),2)+0.01,sprintf('(%d,%d,%d,%d)',k,i,trCount,min(detections(:,2)-syncTimeAcrossCameras(dataset.camera))));
        hold on;
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

