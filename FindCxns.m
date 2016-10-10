function FindCxns(md)
%
%
%

%% Set up. 
    tic; 
    
    %Change directory. 
    cd(md.Location); 
    
    %Load necessary variables. 
    load('TimeCells.mat','TodayTreadmillLog','T');   
    load('Pos_align.mat','FT');
   
    [inds,nRuns] = TrimTrdmllInds(TodayTreadmillLog,T);
    
    nNeurons = size(FT,1); 
    Apval = nan(nNeurons); 
    A = false(nNeurons); 
    
%% 
    %Preallocate. 
    latencies = cell(nNeurons); 
    nullLats = cell(nNeurons);
    rasters = cell(1,nNeurons); 
    critLaps = .25 * nRuns; 
    B = 500;
    
    %Builds all the onset rasters. 
    for n=1:nNeurons
        rasters{n} = buildRaster(inds,FT,n);
    end
    
    %Only look at neurons active on the treadmill for more than critLaps.
    nLapsActive = cell2mat(cellfun(@(x) sum(any(x,2)),rasters,'unif',0)); 
    active = find(nLapsActive > critLaps); 
    nComparisons = nNeurons*nNeurons;
    
%% Construct pairwise spike latencies. 
    resolution = 2;
    updateInc = round(nComparisons/(100/resolution));
    p = ProgressBar(100/resolution);
    parfor c=1:nComparisons
        [src,snk] = ind2sub([nNeurons,nNeurons],c);
        
        if src~=snk && ismember(src,active) && ismember(snk,active)
            latencies{c} = sjlLatFinder(rasters{src},rasters{snk});
            
            tempsrc = rasters{src};
            
            if ~isempty(latencies{c})
                tempnull = cell(1,B);
                for i=1:B
                    tempsrc = permuteTime(tempsrc);
                    tempnull{i} = sjlLatFinder(tempsrc,rasters{snk});                    
                end
                
                %Concatenate. 
                nullLats{c} = cell2mat(tempnull);
                
                %P-value.
                [~,Apval(c)] = kstest2(nullLats{c},latencies{c});
            end
            
            
        end
        
        if round(c/updateInc) == (c/updateInc)
            p.progress;
        end
    end
    p.stop;
    
    for n=1:nNeurons
        pvals = Apval(:,n);
        pvals(isnan(pvals)) = [];
        pvals(pvals==1) = [];
        
        %FDR.
        if ~isempty(pvals)
            [~,pcrit] = fdr_bh(pvals,0.05);
            A(:,n) = Apval(:,n) < pcrit;
        end    
    end
    
    graphData.A = A;
    graphData.Apval = Apval;
    graphData.latencies = latencies; 
    graphData.nullLats = nullLats;
    graphData.Animal = md.Animal;
    graphData.Date = md.Date;
    graphData.Session = md.Session;
    mdInfo.Animal = md.Animal;
    mdInfo.Date = md.Date; 
    mdInfo.Session = md.Session;
    
    elapsed = toc;
    
    save('Cxns.mat','graphData','A','Apval','latencies','nullLats',...
        'mdInfo','elapsed','-v7.3');
end