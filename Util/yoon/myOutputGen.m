function output = myOutputGen(dataset, data)

output = zeros( size(data,1) , 9);

xs = data(:,3);
ys = data(:,4);
ws = data(:,5) - data(:,3);
hs = data(:,6) - data(:,4);

output(:,1) = dataset.camera; % cam
output(:,2) = data(:,1); % id
output(:,3) = data(:,2); % frame
output(:,4:9) = [xs, ys, ws, hs, data(:,7), data(:,8)];

output = sortrows( output, [ 2, 3 ] );
