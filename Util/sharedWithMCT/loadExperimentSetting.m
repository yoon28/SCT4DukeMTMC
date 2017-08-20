function config = loadExperimentSetting(config_file, config)
%LOADEXPERIMENTSETTING Load a configuration file for specific experiment
%   This function takes as input the path of a configuration file and
%   returns a struct containing all the parameters to run the experiment
%   and reproduce the same results over multiple runs.

%% OPEN FILE
if ~exist(config_file, 'file')
    assert('Configuration file doesn''t exist...');
end
fid = fopen(config_file);

%% READ FILE LINE BY LINE
tline = fgetl(fid);
while ischar(tline)
    % skip line if empty or comment
    if isempty(tline) || strcmp(strtrim(tline(1)), '#')
        tline = fgetl(fid); continue;
    end
    
    % split parameter into variable name and value
    C = strsplit(tline,'=');
    for i = 1 : length(C), C{i} = strtrim(C{i}); end
    
    % check if the value is numeric or string
    if ~isempty(C{2}) && ismember(C{2}(1), '0123456789[]-+')
        eval(sprintf('config.%s = %s;', C{1}, C{2}));
    else
        eval(sprintf('config.%s = ''%s'';', C{1}, C{2}));
    end
    
    % read next line
    tline = fgetl(fid);
end

%% CLOSE FILE
fclose(fid);

end