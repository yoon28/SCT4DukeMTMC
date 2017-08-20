function l = ab_swap(w, ig)
%
% optimize CC using ab swaps
%
% Usage:
%   l = ab_swap(w, [ig])
%
% Inputs:
%   w - sparse, symmetric affinity matrix containng BOTH positive and
%       negative entries (attraction and repultion).
%   ig- initial guess labeling (optional)
%
% Output:
%   l - labeling of the nodes into different clusters.
%

% make sure diagonal is zero
n = size(w,1);
w = w - spdiags( spdiags(w, 0), 0, n, n);

if nargin==2
    [NL, ~, l] = unique(ig);
    NL = numel(NL);
else
    l = ones(n,1);
    NL = 1;
end

cE = CCEnergy(w,l);

while 1
    accepted = false;
    
    li = 0;
    
    while li < NL % labels can be added in the iteration...
        li = li+1;
        
        lj = li;
        while lj <= NL % let lj propose a new label
            lj = lj + 1;

            nl = BinarySwap(w, l, li, lj);
            
            nE = CCEnergy(w, nl);
            
            if nE < cE
                % accept move
                cE = nE;
                l = nl;
                accepted = true;
                NL = max(nl(:));
            end
        end
    end
    % stop loop if no changes were made
    if ~accepted
        break;
    end
    % discard "empty" labels
    [NL, ~, l] = unique(l);
    NL = numel(NL);    
end
