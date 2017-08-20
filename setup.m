% Linux specific memory issue, call this first.
ones(10)*ones(10); %#ok

addpath(genpath('Core'), genpath('Util'));

% A valid c++ compiler is needed to use the AL-ICM algorithm
run(fullfile('Core', '3rd party','LargeScaleCC', 'mexall.m'));

% Checks for a valid installation of the Gurobi optimizer.
% Without Gurobi you can still run the AL-ICM-based tracker.
try
%     Change this path accordingly
    run(fullfile(gurobiPath, 'gurobi_setup.m'));
catch
    fprintf('\nWARNING!\n\nGurobi optimizer not found.\nYou can still run the AL-ICM-based tracker.\n');
end