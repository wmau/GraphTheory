function G = MakeGraph_alt(md)
%
%
%

%%
    cd(md.Location); 
    
    load('TimeCells.mat','TodayTreadmillLog','T'); 
    load('Alternation.mat'); 
    
    try 
        load('Pos_align.mat','FT','aviFrame'); 
    catch
        load('FinalOutput.mat','FT');
        [~,~,~,FT] = AlignImagingToTracking(md.Pix2CM,FT,0); 
    end
    
    %Trim indices. 
    inds = TodayTreadmillLog.inds;
    inds = inds(find(TodayTreadmillLog.complete),:);
    inds(:,2) = inds(:,1) + 20*T-1; 
    
    nNeurons = size(FT,1);      %Number of neurons. 
    
    %Build rasters. 
    raster = cell(1,nNeurons);
    for n=1:nNeurons
        raster{n} = buildRaster(inds,FT,n); 
    end
    
%% 
    turn = Alt.summary(Alt.trial(inds(:,1)),2);         %1 = left, 2 = right.
    correct = Alt.summary(Alt.trial(inds(:,1)),3);      %1 = correct, 0 = wrong.
    
    %Lap numbers for left versus right trials. 
    LR{1} = find(turn == 1 & correct);
    LR{2} = find(turn == 2 & correct); 
    LRstring{1} = 'left'; LRstring{2} = 'right';
    
    pLaps = 0.5;
    critLaps = round(cellfun(@(x) length(x), LR).*pLaps); 
    
    %How many laps for both left and right trials was this neuron active? 
    nLapsActive = nan(nNeurons,2);
    activeEnough = false(nNeurons,2);
    for alt = 1:2
        for n = 1:nNeurons
            nLapsActive(n,alt) = sum(any(raster{n}(LR{alt},:),2));
        end
        activeEnough(:,alt) = nLapsActive(:,alt) > critLaps(alt);
    end
    
    good = find(any(activeEnough,2))'; 
    
    nLapsBothActive{1} = nan(nNeurons); nLapsBothActive{2} = nan(nNeurons); 
    closest{1} = cell(nNeurons); closest{2} = cell(nNeurons); 
    CC{1} = cell(nNeurons); CC{2} = cell(nNeurons); 
    Ap{1} = nan(nNeurons); Ap{2} = nan(nNeurons); 
    nulld{1} = cell(nNeurons); nulld{2} = cell(nNeurons);
    A{1} = false(nNeurons); A{2} = false(nNeurons);
    for alt=1:2
        disp(['Analyzing ',LRstring{alt},' trials...']);
        p=ProgressBar(length(good));
        for target=good
            for trigger=good
                if trigger~=target
                    %Get closest spikes of neuron one relative to neuron two. 
                    [immRaster,closest{alt}{trigger,target}] = stripRaster(raster{trigger}(LR{alt},:),...
                        raster{target}(LR{alt},:));

                    %Number of laps where neuron 1 preceded neuron 2. 
                    nLapsBothActive{alt}(trigger,target) = sum(any(immRaster,2)); 

                    if nLapsBothActive{alt}(trigger,target) > critLaps(alt);
                        [CC{alt}{trigger,target},Ap{alt}(trigger,target),nulld{alt}{trigger,target}] = ...
                            lapCC(raster{trigger}(LR{alt},:),raster{target}(LR{alt},:),500); 
                    end
                end
            end
            
            pvals = Ap{alt}(:,target);
            pvals(isnan(pvals)) = []; 
            pvals(pvals==1) = []; 
            
            if ~isempty(pvals)
                [~,pcrit] = fdr_bh(pvals,0.05); 
                A{alt}(:,target) = Ap{alt}(:,target) < pcrit;
            end
            
            p.progress;
        end
        p.stop;
    end
    
    mdInfo.Animal = md.Animal;
    mdInfo.Date = md.Date;
    mdInfo.Session = md.Session;
    
    save('GraphAlt.mat','A','Ap','CC','nulld','closest','mdInfo','-v7.3');
          
end