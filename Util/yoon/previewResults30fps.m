function previewResults30fps(dataset, trackerOutput)
close all;
fprintf('Displaying results...\n');

colors = distinguishable_colors(max(trackerOutput(:,1)));
%count = 1;
h = imshow([]);

myStart = dataset.startingFrame_temp;
myEnd   = dataset.endingFrame_temp;
fastfoward = 15;

for i = myStart : fastfoward : myEnd
    
    image  = readFrame30to60(dataset,i + syncTime30fps(dataset.camera));
    %hold off;
    %imshow(image);
    %hold on;
    
    rows        = find(trackerOutput(:, 2) == i);
    identities  = trackerOutput(rows, 1);
    positions   = [trackerOutput(rows, 3),  trackerOutput(rows, 4), trackerOutput(rows, 5)-trackerOutput(rows, 3), trackerOutput(rows, 6)-trackerOutput(rows, 4)];
    
    if ~isempty(rows)
        frame = insertObjectAnnotation(image,'rectangle', ...
            positions, identities,'TextBoxOpacity', 0.8, 'FontSize', 13, 'Color', 255*colors(identities,:) );
    else
        frame = image;
    end
    %for k = 1 : size(positions, 1)
    %    rectangle('Position', positions(k,:), 'linewidth', 3, 'edgeColor', colors(identities(k),:));
    %end
    
    % Tail
    rows = find((trackerOutput(:, 2) <= i) & (trackerOutput(:,2) >= i - 100));
    identities = trackerOutput(rows, 1);
    
    feetposition = [trackerOutput(rows,3),  trackerOutput(rows,6)];
    
    
%    rectangle('Position', positions(k,:), 'linewidth', 3, 'edgeColor', colors(identities(k),:));
%    end
    
    %frame = insertObjectAnnotation(frame,'circle', ...
    %    feetposition, identities,'Color', 255*colors(identities,:) );
    
    imshow(frame); hold on;
    scatter(feetposition(:, 1), feetposition(:, 2), 20, colors(identities,:), 'filled');
    hold off;
    drawnow;
    title(sprintf('Frame %d',i));
    drawnow;
    set(gcf,'PaperPositionMode','auto');
    %print(fullfile('D:\video', sprintf('%d_%06d.png', dataset.camera, i)),'-dpng','-r0');
%    count = count + 1;
    
end

end

