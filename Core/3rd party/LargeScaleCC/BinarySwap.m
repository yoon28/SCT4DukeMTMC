function nl = BinarySwap(w, l, li, lj)
%
% Performs binary swap move
%
% Usage:
%   nl = BinarySwap(w, l, li, lj)
%
% Inputs:
%   w - sparse, symmetric affinity matrix containng BOTH positive and
%       negative entries (attraction and repultion).
%   l - current labels
%   li, lj - the labels "alpha" and "beta" (resp.) to swap
%
% Output:
%   nl- new labeling of the nodes into different clusters.
%


nl=l;

% reduce the problem
si = l==li;
sj = l==lj;

% in the reduced binary problem 
% l =  0 --> label li was picked for this node
% l =  1 --> label lj was picked for this node


w = w(si|sj, si|sj);
n = size(w,1);
if nnz(w) <= n
    % not enough information
    return
end

% restricted binary initial guess
ig = int32(l(si|sj)==lj); % {0,1} 

[ii jj wij] = find(tril(w,-1));
N = size(w,1);
E = numel(ii);

UTerm = zeros(2,N);

PTerm = zeros(6,E);
PTerm(1,:) = ii;
PTerm(2,:) = jj;
PTerm(3,:) = -wij;
PTerm(4,:) = 0;
PTerm(5,:) = 0;
PTerm(6,:) = -wij;

l = QPBO_wrapper_mex(UTerm, PTerm, ig, 'i');

l = double(l);
assert(all(l>=0) && all(l<=1))

% update the true labeling according to the current swap result
nl(si|sj) = li.*(1-l) + lj.*l;


