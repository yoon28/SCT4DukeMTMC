function MAP = NegativeEnhancingColormap(N, SCALE,  ...
    NEGATIVE_COLOR, POSITIVE_COLOR, ZERO_COLOR, POWER)
% MAP = NegativeEnhancingColormap(N, SCALE, NEG_COLOR, POS_COLOR, ZERO[, POWER=1])
%
% Calculates a colormap that goes from pure red to black for positive
% values (black being zero) and from black to pure blue for negative
% values.
%
% INPUT VARIABLES
% ---------------
%     N: Number of samples of the map.
% SCALE: Two-element vector with [MINV MAXV], being MINV the minimum value
%        of the color scale and MAXV the maximum. Note that MINV must be 
%        negative and MAXV positive.
% NEG_COLOR:
%        (Optional) Color to use for negative values represented as a three
%        RGB component vector. Each component goes from 0 to 1. Default 
%        value is [0 0 1] which corresponds to blue color.%        
% POS_COLOR:
%        (Optional) Color to use for positive values represented as a three
%        RGB component vector. Each component goes from 0 to 1. Default 
%        value is [1 0 0] which corresponds to red color.
%  ZERO: (Optional) Color to use for zero value represented as a three RGB
%        component vector. Each component goes from 0 to 1. Default value 
%        is [0 0 0] which corresponds to white color.
% POWER: (Optional) Power of the interpolation curve for the color. By
%        default is 1 which corresponds to linear interpolation.
%
% OUTPUT VARIABLES
% ----------------
%   MAP: Generated colormap.
%
% LICENSE
% -------
%   Alejandro Cámara (www.acamara.es) 2013
%
%   Negative Enhancing Colormap is licensed under a Creative Commons 
%   Attribution-ShareAlike 3.0 Unported License. For more information
%   visit:
%
%       http://creativecommons.org/licenses/by-sa/3.0/deed.en_US
%
% CHANGELOG
% ---------
%   1.0: Initial released version
%

    % default negative color
    if(nargin < 3 || isempty(NEGATIVE_COLOR))
        NEGATIVE_COLOR = [0 0 1];
    end

    % default positive color
    if(nargin < 4 || isempty(POSITIVE_COLOR))
        POSITIVE_COLOR = [1 0 0];
    end

    % default zero color
    if(nargin < 5 || isempty(ZERO_COLOR))
        ZERO_COLOR = [0 0 0];
    end

    % default power
    if(nargin < 6)
        POWER = 1;
    end

    if(~isvector(SCALE) || numel(SCALE) ~= 2)
        error('SCALE must be a two-element vector.');
    end
    
    MINV = SCALE(1);
    MAXV = SCALE(2);
    if(MINV >= 0 || MAXV <= 0)
        error('MINV must be negative and MAXV positive. None can be zero.');
    end
    
    % initialize map
    MAP = zeros(N, 3);
    
    % calculate zero position
    ZERO_N = round(N*abs(MINV)/(MAXV-MINV));
    
    % calculate number of colors for positive or negative
    NUM_POSITIVE = N - ZERO_N;
    NUM_NEGATIVE = ZERO_N - 1;
    
    % place red, blue, and black
    MAP(1, :) = NEGATIVE_COLOR;
    MAP(end, :) = POSITIVE_COLOR;
    MAP(ZERO_N, :) = ZERO_COLOR;
    
    for(K=2:N-1)
        if(K < ZERO_N)
            INTERPV = 1 - K/(NUM_NEGATIVE+1);
            INTERPV = INTERPV^POWER;
            MAP(K, :) = (1-INTERPV)*ZERO_COLOR + INTERPV*NEGATIVE_COLOR;
        elseif(K > ZERO_N)
            INTERPV = (K-ZERO_N)/(NUM_POSITIVE+1);
            INTERPV = INTERPV^POWER;
            MAP(K, :) = (1-INTERPV)*ZERO_COLOR + INTERPV*POSITIVE_COLOR;
        end
    end
    
    % make it unique
    [~, INDEX] = unique(MAP, 'rows', 'first');
    MAP = MAP(sort(INDEX), :);
end