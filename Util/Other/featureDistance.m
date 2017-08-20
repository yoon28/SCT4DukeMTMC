function [ distance ] = featureDistance( feature1, feature2, distanceType)

switch distanceType
    
    case 'histogram_intersection'
        K = histogramIntersection(feature1, feature2);
        distance = sum(K(:));
        
    case 'L1'
        distance = norm(feature1-feature2,1);
  
    case 'L2'
        distance = norm(feature1-feature2,2);
            
    otherwise
        distance = norm(feature1-feature2,inf);
        
end