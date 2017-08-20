function nl = BinaryExpand(w, l, li)
%
% Performs binary expand move
%
% Usage:
%   nl = BinaryExpand(w, l, li)
%
% Inputs:
%   w - sparse, symmetric affinity matrix containng BOTH positive and
%       negative entries (attraction and repultion).
%   l - current labels
%   li- the label "alpha" to expand
%
% Output:
%   nl- new labeling of the nodes into different clusters.
%


nl=l;


% in the reduced binary problem 
% l = 0 --> retain prev label  
% l = 1 --> label li (alpha) was picked for this node

% nodes that are already labeled li - are not participating
% node that has nieghbor with label li will have a unary term instead of
% the pair-wise with the removed li labeled nieghbor


non_li = l~=li;

n = sum(non_li);

if n == 0
    % all labels are a - no need to expand.
    return;
end

% fprintf(1, '%d, ', n);

% unary term takes into account the li nieghbors
UTerm = zeros(2,n);
UTerm(1,:) = full( sum( w(non_li, ~non_li), 2).' );

% only non li label nodes participating
rl = l(non_li);
[ii jj wij] = find(w(non_li,non_li));

%select lower tri of w
lt = ii > jj;
ii = ii(lt);
jj = jj(lt);
wij = wij(lt);

E = numel(ii);

PTerm = zeros(6,E);
PTerm(1,:) = ii;
PTerm(2,:) = jj;
PTerm(3,:) = wij.*double(rl(ii)~=rl(jj));
PTerm(4,:) = wij;
PTerm(5,:) = wij;
PTerm(6,:) = 0;

ig = zeros(n,1);

X = QPBO_wrapper_mex(UTerm, PTerm, int32(ig), 'i');
X(X<0) = ig(X<0); % unlabeled - retain prev solution

rl(X==1) = li;
nl(non_li) = rl;



