function allMets=evaluateTracking(s, groundTruth, trackerData)
%% evaluate CLEAR MOT and other metrics
% concatenate ALL sequences and evaluate as one!
%
% SETUP:
%
% define directories for tracking results...
% resDir = fullfile('res','data',filesep);
% ... and the actual sequences
% dataDir = fullfile('..','data','2DMOT2015','train',filesep);
%
%

if (~isdeployed)
       addpath(genpath('.'));
end

% read sequence map
%seqmapFile=fullfile('seqmaps',seqmap);
%allSeq = parseSequences(seqmapFile);

%fprintf('Sequences: \n');
%disp(s)


% concat gtInfo
gtInfo=[];
gtInfo.X=[];
allFgt=zeros(1,1);

% Find out the length of each sequence
% and concatenate ground truth
gtInfoSingle=[];
seqCnt=0;
seqCnt=seqCnt+1;
seqName = s;

%assert(isdir(seqFolder),'Sequence folder %s missing',seqFolder);

%gtFile = fullfile(dataDir,seqName,'gt','gt.txt');
gtI = convertTXTToStruct(groundTruth);

[Fgt,Ngt] = size(gtInfo.X);
[FgtI,NgtI] = size(gtI.Xi);
newFgt = Fgt+1:Fgt+FgtI;
newNgt = Ngt+1:Ngt+NgtI;

gtInfo.Xi(newFgt,newNgt) = gtI.Xi;
gtInfo.Yi(newFgt,newNgt) = gtI.Yi;
gtInfo.W(newFgt,newNgt) = gtI.W;
gtInfo.H(newFgt,newNgt) = gtI.H;

gtInfoSingle(seqCnt).wc=0;

% fill in world coordinates if they exist
if isfield(gtI,'Xgp') && isfield(gtI,'Ygp')
    gtInfo.Xgp(newFgt,newNgt) = gtI.Xgp;
    gtInfo.Ygp(newFgt,newNgt) = gtI.Ygp;
    gtInfoSingle(seqCnt).wc=1;
end

% check if bounding boxes available in solution
imCoord=1;
if all(gtI.Xi(find(gtI.Xi(:)))==-1)
    imCoord=0;
end

gtInfo.X=gtInfo.Xi;gtInfo.Y=gtInfo.Yi;
if ~imCoord
    gtInfo.X=gtInfo.Xgp;gtInfo.Y=gtInfo.Ygp;
end

allFgt(seqCnt) = FgtI;

gtInfoSingle(seqCnt).gtInfo=gtI;

gtInfo.frameNums=1:size(gtInfo.Xi,1);

allMets=[];

mcnt=1;


%fprintf('Evaluating ... \n');


clear stInfo
stInfo.Xi=[];

evalMethod=1;

% flags for entire benchmark
% if one seq missing, evaluation impossible
eval2D=1;
eval3D=1;

seqCnt=0;

% iterate over each sequence

seqCnt=seqCnt+1;

%fprintf('\t... %s\n',seqName);


stI = convertTXTToStruct(trackerData, gtInfo.frameNums);
%     stI.Xi(find(stI.Xi(:)))=-1;
% check if bounding boxes available in solution
imCoord=1;
if all(stI.Xi(find(stI.Xi(:)))==-1)
    imCoord=0;
end

worldCoordST=0; % state
if isfield(stI,'Xgp') && isfield(stI,'Ygp')
    worldCoordST=1;
end

[FI,NI] = size(stI.Xi);


% if stateInfo shorter, pad with zeros
% GT and result must be equal length
if FI<allFgt(seqCnt)
    missingFrames = FI+1:allFgt(seqCnt);
    stI.Xi(missingFrames,:)=0;
    stI.Yi(missingFrames,:)=0;
    stI.W(missingFrames,:)=0;
    stI.H(missingFrames,:)=0;
    stI.X(missingFrames,:)=0;
    stI.Y(missingFrames,:)=0;
    if worldCoordST
        stI.Xgp(missingFrames,:)=0; stI.Ygp(missingFrames,:)=0;
    end
    [FI,NI] = size(stI.Xi);
    
end

% get result for one sequence only
[mets, mInf]=CLEAR_MOT_HUN(gtInfoSingle(seqCnt).gtInfo,stI);

allMets(mcnt).mets2d(seqCnt).name=seqName;
allMets(mcnt).mets2d(seqCnt).m=mets;

allMets(mcnt).mets3d(seqCnt).name=seqName;
allMets(mcnt).mets3d(seqCnt).m=zeros(1,length(mets));

% if imCoord
%     fprintf('*** 2D (Bounding Box overlap) ***\n'); printMetrics(mets); fprintf('\n');
% else
%     fprintf('*** Bounding boxes not available ***\n\n');
%     eval2D=0;
% end

% 
% 
% 
% [F,N] = size(stInfo.Xi);
% newF = F+1:F+FI;
% newN = N+1:N+NI;
% 
% % concat result
% stInfo.Xi(newF,newN) = stI.Xi;
% stInfo.Yi(newF,newN) = stI.Yi;
% stInfo.W(newF,newN) = stI.W;
% stInfo.H(newF,newN) = stI.H;
% if isfield(stI,'Xgp') && isfield(stI,'Ygp')
%     stInfo.Xgp(newF,newN) = stI.Xgp;stInfo.Ygp(newF,newN) = stI.Ygp;
% end
% stInfo.X=stInfo.Xi;stInfo.Y=stInfo.Yi;
% if ~imCoord
%     stInfo.X=stInfo.Xgp;stInfo.Y=stInfo.Ygp;
% end
% 
% stInfo.frameNums=1:size(stInfo.Xi,1);
% 
% if eval2D
%     fprintf('\n');
%     fprintf(' ********************* Your Benchmark Results (2D) ***********************\n');
%     
%     [m2d, mInf]=CLEAR_MOT_HUN(gtInfo,stInfo);
%     allMets.bmark2d=m2d;
%     
%     %evalFile = fullfile(resDir, 'eval2D.txt');
%     
%     printMetrics(m2d);
%     %dlmwrite(evalFile,m2d);
% end
% 
% if eval3D
%     fprintf('\n');
%     fprintf(' ********************* Your Benchmark Results (3D) ***********************\n');
%     
%     evopt.eval3d=1;evopt.td=1;
%     
%     [m3d, mInf]=CLEAR_MOT_HUN(gtInfo,stInfo,evopt);
%     allMets.bmark3d=m3d;
%     
%     %evalFile = fullfile(resDir, 'eval3D.txt');
%     
%     printMetrics(m3d);
%     %dlmwrite(evalFile,m3d);
% end
% if ~eval2D && ~eval3D
%     fprintf('ERROR: results cannot be evaluated\n');
% end
