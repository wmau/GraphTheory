function graphData = FindCxns(md)
%graphData = FindCxns(md)
%
%   Parallelized version of MakeGraphv4.m. For each neuron pair, do a
%   random card shuffle permutation in time for each lap then compare
%   distributions of latencise. Assign an edge wherever there is a
%   significant difference.
%
%   INPUT
%       md: Session entry.
%
%   OUPUT
%       graphData: struct with fields
%           A: adjacency matrix.
%           Apval: p-value of KS test of empirical vs time shuffled data.
%           latencies: latency distribution.
%           nullLats: time shuffled latency distribution.
%           Animal,Date,Session: from md.
%   

%% Set up. 
    tic; 
    
    %Change directory. 
    cd(md.Location); 
    
    %Load necessary variables. 
    load('TimeCells.mat','TodayTreadmillLog','T');   
    load('Pos_align.mat','PSAbool');
   
    %Trim treadmill indices.
    [inds,nRuns] = TrimTrdmllInds(TodayTreadmillLog,T); 
    nNeurons = size(PSAbool,1); 
    
    %Preallocate. 
    Atpval = nan(nNeurons); 
    a = false(nNeurons); 
    latencies = cell(nNeurons); 
    tNullLats = cell(nNeurons);
    rasters = cell(1,nNeurons); 
    critLaps = .25 * nRuns; 
    B = 500;
    
    %Builds all the onset rasters. 
    for n=1:nNeurons
        rasters{n} = buildRaster(inds,PSAbool,n);
    end
    
    %Only look at neurons active on the treadmill for more than critLaps.
    nLapsActive = cell2mat(cellfun(@(x) sum(any(x,2)),rasters,'unif',0)); 
    active = find(nLapsActive > critLaps); 
    nComparisons = nNeurons*nNeurons;
    
%% Construct pairwise spike latencies. 
    %Build progress bar.
    disp('Performing time shuffles...');
   
    %Perform comparisons.
    parpool('local');
    resolution = 2;
    updateInc = round(nComparisons/(100/resolution));
    p = ProgressBar(100/resolution);
    parfor c=1:nComparisons
        %Get row,column indices.
        [src,snk] = ind2sub([nNeurons,nNeurons],c);
        
        %Omit comparisons between same neuron. Only look at active neurons.
        if src~=snk && ismember(src,active) && ismember(snk,active)
            %Get empirical latency distribution.
            latencies{c} = sjlLatFinder(rasters{src},rasters{snk});
            
            %Permute time then find latency distribution again.            
            if length(latencies{c}) >= critLaps
                tempsrc = rasters{src};
                tempnull = cell(1,B);
                
                for i=1:B
                    tempnull{i} = sjlLatFinder(permuteTime(tempsrc),rasters{snk});                    
                end
                
                %Concatenate null latency distributions.
                tNullLats{c} = cell2mat(tempnull);
                
                if length(tNullLats{c}) >= critLaps
                    %P-value.
                    [~,Atpval(c)] = kstest2(tNullLats{c},latencies{c});
                else 
                    Atpval(c) = nan;
                end
            else 
                Atpval(c) = nan;
            end
        else 
            Atpval(c) = nan;    
        end
        
        %Update progress bar. 
        if round(c/updateInc) == (c/updateInc)
            p.progress;
        end
    end
    p.stop;
    delete(gcp);
    
%% Build adjacency matrix.
    for n=1:nNeurons
        %Get p-values and excise bad ones.
        pvals = Atpval(:,n);
        pvals(isnan(pvals)) = [];
        pvals(pvals==1) = [];
        
        %FDR.
        if ~isempty(pvals)
            [~,pcrit] = fdr_bh(pvals,0.05);
            a(:,n) = Atpval(:,n) < pcrit;
        end    
    end
    
%% Perform trial shuffle. 
    [A,Atrlpval,trlNullLats] = trlShfflTest(md,a,latencies); 
    
%% Construct structs.
    graphData.a = a;
    graphData.A = A; 
    graphData.Atpval = Atpval;
    graphData.Atrlpval = Atrlpval;
    graphData.latencies = latencies; 
    graphData.tNullLats = tNullLats;
    graphData.trlNullLats = trlNullLats;
    graphData.Animal = md.Animal;
    graphData.Date = md.Date;
    graphData.Session = md.Session;
    mdInfo.Animal = md.Animal;
    mdInfo.Date = md.Date; 
    mdInfo.Session = md.Session;
    
    elapsed = toc;

%% Save. 
    save('GRAPH.mat','graphData','a','A','Atpval','Atrlpval','latencies',...
        'tNullLats','trlNullLats','mdInfo','elapsed','-v7.3');
end