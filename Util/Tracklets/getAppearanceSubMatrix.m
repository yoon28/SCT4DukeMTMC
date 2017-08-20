function [ correlation ] = getAppearanceSubMatrix(observations, featureVectors, distanceType, alpha )

features = cell2mat(featureVectors.appearance(observations));

correlation = 1 - alpha*pdist2(features,features,@histogramIntersection);
correlation = max(0, correlation);




