function graphData = MakeGraphv4(md)
%graphData = MakeGraphv4(md)
%
%

%% Load traces and align to imaging. 
    tic;
    
    cd(md.Location);
    
    load('TimeCells.mat','TodayTreadmillLog','T');
   
    try 
        load('Pos_align.mat','FT'); 
    catch
        load('FinalOutput.mat','FT');
        [~,~,~,FT] = AlignImagingToTracking(md.Pix2CM,FT,0); 
    end
    
    inds = TodayTreadmillLog.inds;
    inds = inds(find(TodayTreadmillLog.complete),:);        %Only completed runs. 
    nRuns = sum(TodayTreadmillLog.complete); 

    inds(:,2) = inds(:,1) + 20*T-1;                         %Consistent length.
        
    %Preallocate connectivity matrix. 
    nNeurons = size(FT,1);
    Ap = nan(nNeurons); 
    A = false(nNeurons);
    
%% Construct vectors.
    %Preallocate.
    CC = cell(nNeurons); 
    closest = cell(nNeurons);
    nulld = cell(nNeurons);
    raster = cell(1,nNeurons);
    %lapsActive = cell(1,nNeurons);
    critLaps = 0.25*nRuns;
    
    %dt = 0.05;              %Bin size, seconds. 
    %window = 10;            %Window of interest, seconds. 
    %nBins = window/dt; 
    
    %Build all the rasters.
    for n=1:nNeurons
        raster{n} = buildRaster(inds,FT,n);    
    end
    
    %Only look at neurons active on the treadmill for more than critLaps.
    nLapsActive = cell2mat(cellfun(@(x) sum(any(x,2)), raster, 'unif',0));
    active = find(nLapsActive > critLaps);
    
    %nLapsBothActive = zeros(nNeurons);
    
%% Construct pairwise spike differences. 
    %For each neuron...
    p = ProgressBar(length(active));
    for two=active
        for one=active         
            if one ~= two %&& nLapsBothActive > critLaps
                %Get the closest spikes of neuron one relative to neuron
                %two.  
                [i,closest{one,two}] = stripRaster(raster{one},raster{two});
                
                %Get the temporal distances between spikes of neuron one
                %relative to neuron two plus the p-value and null
                %distributions associated with shuffling B times.    
                if sum(any(i,2)) > critLaps
                    [CC{one,two},Ap(one,two),nulld{one,two}] = lapCC(raster{one},raster{two},500);    
                end
            end     
        end 
        
        pvals = Ap(:,two);
        pvals(isnan(pvals)) = [];
        pvals(pvals == 1) = [];

        %FDR.
        if ~isempty(pvals)
            [~,pcrit] = fdr_bh(pvals,0.05);
            A(:,two) = Ap(:,two) < pcrit;
        end       
        p.progress;
    end
    p.stop;
    
    graphData.A = A; 
    graphData.Ap = Ap; 
    graphData.CC = CC;
    graphData.nulld = nulld;
    graphData.closest = closest;
    graphData.Animal = md.Animal;
    graphData.Date = md.Date;
    graphData.Session = md.Session;
    mdInfo.Animal = md.Animal; 
    mdInfo.Date = md.Date;
    mdInfo.Session = md.Session;
    
    elapsed = toc; 
    save('Graphv4.mat','graphData','A','Ap','CC','nulld','closest','mdInfo',...
        'elapsed','-v7.3');
end