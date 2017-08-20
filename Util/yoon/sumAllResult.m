
cams = [1,2,3,4,5,6,7,8];
times = [120000, 190000];
results_all = [];
idoffsets = 0;
for i=1:length(cams)
    fname = sprintf('../../results/cam%d_%07d_%07d.txt', cams(i), times(1), times(2));
    result = load(fname);
    result(:,2) = result(:,2) + idoffsets;
    results_all = [results_all; result];
    idoffsets = idoffsets + max(result(:,2));
end

results_all = sortrows(results_all,[1 2 3]);
dlmwrite('../../results/sct_all.txt', results_all, 'delimiter', ' ', 'precision', 6);