function output = myOutputGen30to60(dataset, data)

output_tmp = zeros( size(data,1) , 9);

xs = data(:,3);
ys = data(:,4);
ws = data(:,5) - data(:,3);
hs = data(:,6) - data(:,4);

output_tmp(:,1) = dataset.camera; % cam
output_tmp(:,2) = data(:,1); % id
output_tmp(:,3) = data(:,2); % frame
output_tmp(:,4:9) = [xs, ys, ws, hs, data(:,7), data(:,8)];

output_tmp = sortrows( output_tmp, [ 2, 3 ] );

ids = unique(output_tmp(:,2));

output = [];
for i = 1 : length(ids)
   
    track30 = output_tmp( output_tmp(:,2) == ids(i), : );
    if track30(1,3)*2-syncTimeAcrossCameras(dataset.camera) < dataset.startingFrame || track30(end,3)*2-syncTimeAcrossCameras(dataset.camera) > dataset.endingFrame
        [dataset.camera, ids(i)]
        error('check time!');
    end
    
    newlen = size(track30,1)*2;
    track60 = zeros(newlen ,9);
    track60(:,1) = track30(1,1);
    track60(:,2) = track30(1,2);
    
    track30(:,3) = track30(:,3).*2;
    track60(:,3) = (0:newlen-1)' + track30(1,3);
    
    track60(:,4) = interp1( track30(:,3), track30(:,4), track60(:,3), 'spline' );
    track60(:,5) = interp1( track30(:,3), track30(:,5), track60(:,3), 'spline' );
    track60(:,6) = interp1( track30(:,3), track30(:,6), track60(:,3), 'spline' );
    track60(:,7) = interp1( track30(:,3), track30(:,7), track60(:,3), 'spline' );
    track60(:,8) = interp1( track30(:,3), track30(:,8), track60(:,3), 'spline' );
    track60(:,9) = interp1( track30(:,3), track30(:,9), track60(:,3), 'spline' );
    
    output = [output; track60];
end

output = sortrows( output, [2,3]);