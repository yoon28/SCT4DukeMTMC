function [gt w] = MakeSynthAff(n, cs, deg, bal, noise)
%
% Make a synthetic noisy adjacency matrix
%
% Usgae:
%   [gt w] = MakeSynthAff(n, cs, deg, noise)
%
% Inputs:
%   n   - number of variables
%   cs  - cluster size, a vector of length num_clusters, with positive
%         entires reflecting the expected relative size of each cluster
%   deg - degree of adjacency matrix (number of neighbors for each variable)
%   bal - 0<bal<1 balance between number of inter and intra cluster nieghbors
%   noise fraction of entries to be fliped 0<=noise<=1
%
%
% Outputs:
%   gt  - nx1 ground truth labels
%   w   - nxn (sparse) noisy affinity matrix
%


assert( numel(n) == 1 && n == round(n) );
assert( all(cs > 0) );
assert( numel(deg) == 1 && deg == round(deg) );
assert( numel(noise) == 1 && noise >=0 && noise <= 1 );
assert( numel(bal)==1 && bal>0 && bal < 1 );

cs = cumsum(cs)./sum(cs);
NL = numel(cs);

% ground truth
[~, gt] = max( bsxfun(@le, rand(n,1), cs), [], 2);

cs = hist(gt,1:NL); % actual cluster sizes

% nic = min(min(cs), round(bal*deg)); % number of neighbors in cluster 
nic = max(1, round(bal*deg)); % number of neighbors in cluster 
nac = max(1, deg-nic); % number of neighbors across cluster

ind = 1:n;

jj = zeros(n, nic+nac);
for ii=1:n
    li = gt(ii);
    jj(ii, 1:nic) = randsample(ind(gt==li), nic, true);
    jj(ii, nic+(1:nac)) = randsample(ind(gt~=li), nac, true);
end

ii = repmat(ind', 1, nic+nac);

w = sparse(ii(:), jj(:), 1);
w = w+w';
[ii jj] = find(w);
sel = ii<jj;
ii = ii(sel);
jj = jj(sel);

wij = 2*(gt(ii(:))==gt(jj(:)))-1; % ground truth incidents
E = numel(wij);

sig=1; % how "peak"y is the distribution
% make "predictor-like" noise
mu = - erfinv(2*noise-1)*sqrt(2)*sig;
r = sig*randn(1,E)+mu;
wij = wij(:).*r(:);

assert( all(~isnan(wij)) && all(~isinf(wij)) );

w = sparse(ii,jj,wij,n,n);
w = w+w';


