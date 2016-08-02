function graphData_KS = KSpruneA_alt(md,graphData) 
%
%
%

%%
    cd(md.Location); 
    
    graphData_KS = graphData; 
    nNeurons = size(graphData_KS.A{1},1); 
    
    load(fullfile(md.Location,'Pos_align.mat'),'FT');
    load(fullfile(md.Location,'TimeCells.mat'),'TodayTreadmillLog','T');
    load(fullfile(md.Location,'Alternation.mat')); 
    
    inds = TodayTreadmillLog.inds(find(TodayTreadmillLog.complete),:);
    inds(:,2) = inds(:,1) + 20*T-1;
    
%% 
    LRstring = {'left','right'};
    correct = Alt.summary(:,3); 
       
    for alt = 1:2
        lr = Alt.summary(:,2) == alt; 
        
        graphData_KS.p{alt} = nan(nNeurons); 
        
        disp(['Analyzing ',LRstring{alt},' trials...']); 
        p = ProgressBar(nNeurons); 
        for n=1:nNeurons
            el = find(graphData.A{alt}(:,n))';
            targRaster = buildRaster(inds,FT,n); 
            
            targRaster = targRaster(lr & correct,:);
            
            for e=el
                trigRaster = buildRaster(inds,FT,e); 
                trigRaster = trigRaster(lr & correct,:); 
                
                [immRaster,TTLatencies] = stripRaster(trigRaster,targRaster); 
                
                %From those, find the treadmill-target latencies.
                TMAlignedOnsets = TMLatencies(immRaster,targRaster);
                   
                TTLatencies = TTLatencies./min(TTLatencies);
                TMAlignedOnsets = TMAlignedOnsets./max(TMAlignedOnsets); 

                %KS-test. 
                [~,graphData_KS.p{alt}(e,n)] = kstest2(TTLatencies,TMAlignedOnsets);
            end
            
            if any(graphData_KS.p{alt}(:,n))
                pvals = graphData_KS.p{alt}(:,n);
                pvals = pvals(~isnan(pvals)); 
                
                [~,pcrit] = fdr_bh(pvals,0.05); 
                
                graphData_KS.A{alt}(:,n) = graphData_KS.p{alt}(:,n) < pcrit; 
            end
           
            p.progress;
        end
        p.stop;
    end
    
end