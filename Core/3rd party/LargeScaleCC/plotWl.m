function plotWl(W,l)
%
% plot an affinity matrix ordered according to labeling l
%
% Usage:
%   plotWl(w, l)
%

l=l(:);
[si si] = sort(l(:));
n = hist(l,min(l(:)):max(l(:)));

N = size(W,1);
figure;
imagesc(W(si,si));axis image;colormap gray;impixelinfo
hold on;
csn = cumsum(n);
nl=numel(csn)-1;
csn=csn+.5;
plot( repmat([1 N]',[1 nl]), repmat( csn(1:end-1), [2 1]), '-r');
plot( repmat( csn(1:end-1), [2 1]), repmat([1 N]',[1 nl]), '-r');
