function [ appearanceMatrix ] = getAppearanceMatrix(featureVectors, distanceType, alpha )

% Computes the appearance affinity matrix

numFeatures = length(featureVectors);
appearanceMatrix = zeros(numFeatures); 

features = cell2mat(featureVectors');

correlation = 1 - alpha*pdist2(features,features,@histogramIntersection);
correlation = max(0, correlation);
appearanceMatrix = correlation;
return;


% Compute pairwise correlations

for i = 1:numFeatures
    
    for j = i + 1:numFeatures
       
       
        appearanceMatrix(i,j) =  1 - alpha*featureDistance( ...
                featureVectors{i}, featureVectors{j}, distanceType);
            
        appearanceMatrix(i,j) = max( 0, appearanceMatrix(i,j) );

       
        appearanceMatrix(j,i) = appearanceMatrix(i,j);
        
    end
    
end

for i = 1:numFeatures
    appearanceMatrix(i,i) = 1;
end






