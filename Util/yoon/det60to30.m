clear;
close all;

for i = 1 : 8
    fname = sprintf('/storage2/datasets/DukeMTMC/detections/camera%d.mat',i); % locate the original detection data
    load(fname);
    
    newdet = [];
    idx = rem(detections(:,2),2) == 0;
    newdet = detections( idx, : );
    newdet(:,2) = newdet(:,2)./2;
    
    svname = sprintf('/storage2/datasets/DukeMTMC/detections/det30/camera%d_30.mat',i); % set a new file name for new detection data
    save(svname, 'newdet', '-v7.3');
    
    clear detections;
end