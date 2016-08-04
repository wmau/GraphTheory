function graphData_KS = KSpruneA(md,graphData)
%graphData_KS = KSpruneA(md,graphData)
%
%   Prune the adjacency matrix using method #2. Calculate latencies between
%   cell pairs and the target cell with treadmill onset. Normalize then
%   KS-test to compare these two latency distributions. Place an edge if
%   there is a significant difference (corrected for multiple comparisons).
%   
%   INPUTS
%       md: Session entry. 
%
%       graphData: Initial graphData variable from MakeGraphv4. 
%
%   OUTPUT
%       graphData_KS: Pruned version of graphData with fields: 
%           A: Pruned adjacency matrix.
%           p: P-value of the KS-test.
%           All other fields from graphData. 
%

%% Set up. 
    cd(md.Location); 
    
    graphData_KS = graphData; 
    nNeurons = size(graphData_KS.A,1); 
    graphData_KS.p = nan(nNeurons); 
  
    load(fullfile(md.Location,'Pos_align.mat'),'FT');
    load(fullfile(md.Location,'TimeCells.mat'),'TodayTreadmillLog','T');
    
    inds = TodayTreadmillLog.inds(find(TodayTreadmillLog.complete),:);
    inds(:,2) = inds(:,1) + 20*T-1;

%% Do the pruning. 
    p = ProgressBar(nNeurons);
    %For each target...
    for n=1:nNeurons
        %Get putative triggers. 
        el = find(graphData.A(:,n))';
        targRaster = buildRaster(inds,FT,n);
        
        %For each trigger...
        for e=el
            %Get raster for the trigger cells.
            trigRaster = buildRaster(inds,FT,e);
            [immRaster,TTLatencies] = stripRaster(trigRaster,targRaster);
            
            %From those, find the treadmill-target latencies.
            TMAlignedOnsets = TMLatencies(immRaster,targRaster);
            
            %Normalize
            TTLatencies = TTLatencies./min(TTLatencies); 
            TMAlignedOnsets = TMAlignedOnsets./max(TMAlignedOnsets); 
            
            %KS-test. 
            [~,graphData_KS.p(e,n)] = kstest2(TTLatencies,TMAlignedOnsets);
        end
        
        if any(graphData_KS.p(:,n));
            %Get p-values. 
            pvals = graphData_KS.p(:,n); 
            pvals = pvals(~isnan(pvals)); 

            %Multiple comparisons correction.
            [~,pcrit] = fdr_bh(pvals,0.05); 

            %Declare edges.
            graphData_KS.A(:,n) = graphData_KS.p(:,n) < pcrit; 
        end

        p.progress;
    end
    p.stop;
    
    A = graphData_KS.A; 
    p = graphData_KS.p;
    mdInfo.Animal = graphData.Animal;
    mdInfo.Date = graphData.Date;
    mdInfo.Session = graphData.Session;
    nulld = graphData.nulld;
    CC = graphData.lagMat; 
    
    save('graphData_KS.mat','graphData_KS','A','p','mdInfo','null','CC','-v7.3');
end