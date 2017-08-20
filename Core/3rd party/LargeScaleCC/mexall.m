function mexall
%
% Call this function to compile any associated mex-files
%

mex -O -largeArrayDims pure_potts_icm_iter_mex.cpp
mex -O -largeArrayDims CC_energy_mex.cpp -output CCEnergy

% QPBO compilation
cd('QPBO-v1.3.src');
mex -O -largeArrayDims CXXFLAGS="\$CXXFLAGS -Wno-write-strings" QPBO.cpp QPBO_extra.cpp QPBO_maxflow.cpp QPBO_wrapper_mex.cpp QPBO_postprocessing.cpp -output QPBO_wrapper_mex
cd('..');

copyfile(fullfile('QPBO-v1.3.src',['QPBO_wrapper_mex.',mexext]),'.');
