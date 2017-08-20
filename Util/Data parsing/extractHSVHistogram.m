function [ feature ] = extractHSVHistogram( image )

binsH = 16;
binsS = 16;
binsV = 4;

img = rgb2hsv(image); 

h = img(:,:,1);
s = img(:,:,2);
v = img(:,:,3);
    
[histH, ~] = HIST(h(:),binsH); % hist(h(:),binsH);
[histS, ~] = HIST(s(:),binsS); % hist(s(:),binsS);
[histV, ~] = HIST(v(:),binsV); % hist(v(:),binsV);

feature = [histH, histS, histV];
feature = feature/(eps+sum(feature));