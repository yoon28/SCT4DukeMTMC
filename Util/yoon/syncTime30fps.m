function out = syncTime30fps(cam)

% this function should return the proper frame shift with respect camera 5(the master camera) in 30 fps setting.
% usage example:
% (time stamp of master cam) + syncTime30fps(cam_num) = (corresponding time stamp of cam_num)
% (time stamp of cam_num) - syncTime30fps(cam_num) = (corresponding time stamp of master cam)
% All the time stamp used for this fucntion are in 30fps.

switch cam
    
    case 1, out = -round(5543/2)+1;
    case 2, out = -round(3607/2)+1;
    case 3, out = -round(27244/2)+1;
    case 4, out = -round(31182/2)+1;
    case 5, out = -1+1;
    case 6, out = -round(22402/2)+1;
    case 7, out = -round(18968/2)+1;
    case 8, out = -round(46766/2)+1;
        
end

