% function E = CCEnergy(w, l)
% %
% % Computes the correlation-clustering energy of a labeling l
% %
% % E = -trace(u'Wu)  
% %
% % Usage:
% %   E = CCEnergy(w, l)
% %
% % Inputs:
% %   w   - square affinity matrix
% %   l   - labeling vector
% %

% 
% u = l2u(l);
% E =  -u.*(w*u);
% seE = sum(E(:));
