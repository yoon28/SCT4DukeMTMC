function  exportMovie( dataset, trackerOutput )

grouping = '_NoGroup';
if dataset.useGrouping == true
    grouping = '';
end

foldername = sprintf('%s-%s%s',dataset.name, dataset.method{1},grouping);
mkdir(fullfile('Output',foldername));
observations = trackerOutput;

[x ia ic] = unique(observations(:,1));
% observations(:,1) = ic;
observations(:,1) = observations(:,1) + 1;

colors = distinguishable_colors(max(observations(:,1)));

count = 1;

for i=1:1:dataset.numberOfFrames
    
    clc
    fprintf('Exporting frame %d/%d\n',i,dataset.numberOfFrames);
    
    
    image  = readFrame(dataset,i);
    
    rows = find(observations(:,2)==i);
    identities = observations(rows,1);
    positions = [ observations(rows,3),  observations(rows,4), observations(rows,5)-observations(rows,3), observations(rows,6)-observations(rows,4)];
   
    frame = insertObjectAnnotation(image,'rectangle', ...
        positions, identities,'TextBoxOpacity', 0.8, 'FontSize', 13, 'Color', 255*colors(identities,:) );
    
    
    imwrite( frame, fullfile('Output', foldername, sprintf('frame-%08d.jpeg' ,count) ));
    count = count + 1;
    
    
    
end



