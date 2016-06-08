function MakeGraphv4(md)
%
%
%

%% Load traces and align to imaging. 
    cd(md.Location);
    
    load('TimeCells.mat','TodayTreadmillLog','T');
   
    if ~isfield(TodayTreadmillLog,'inds')
        try 
            load('Pos_align.mat','FT','aviFrame'); 
        catch
            load('T2output.mat','FT');
            [~,~,~,FT,~,~,aviFrame] = AlignImagingtoTracking(md.Pix2CM,FT,0); 
        end
        nNeurons = size(FT,1);

        inds = getTreadmillEpochs(TodayTreadmillLog,aviFrame); 
        inds = inds(find(TodayTreadmillLog.complete),:);    %Only completed runs. 
        nLaps = sum(TodayTreadmillLog.complete); 
    else
        inds = TodayTreadmillLog.inds;
        nLaps = sum(TodayTreadmillLog.complete); 
    end
    
    inds(:,2) = inds(:,1) + 20*T-1;                         %Consistent length.
        
    %Preallocate connectivity matrix. 
    nNeurons = size(FT,1);
    Ap = nan(nNeurons); 
    A = false(nNeurons);
   
    
%% Construct vectors of closest cell firing.
    %Preallocate.
    CC = cell(nNeurons); 
    closest = cell(nNeurons);
    null = cell(nNeurons);
    raster = cell(1,nNeurons);
    critLaps = 0.25*nLaps;
    
    dt = 0.05;              %Bin size, seconds. 
    window = 10;            %Window of interest, seconds. 
    nBins = window/dt; 
    
    %Build all the rasters.
    for n=1:nNeurons
        raster{n} = buildRaster(inds,FT,n);
    end
    
    %Only look at neurons active on the treadmill.
    active = find(cellfun(@(x) any(x(:)), raster));
    
%% Construct pairwise spike differences. 
    %For each neuron...
    p = ProgressBar(nNeurons);
    for two=active
        for one=active        
            if one ~= two
                %Get the temporal distances between spikes of neuron one
                %relative to neuron two plus the p-value and null
                %distributions associated with shuffling B times. 
                [CC{one,two},Ap(one,two),null{one,two}] = lapCC(raster{one},raster{two},500);
                
                %Get the closest spikes of neuron one relative to neuron
                %two.
                [~,closest{one,two}] = stripRaster(raster{one},raster{two});
            end     
        
            pvals = Ap(:,two);
            pvals(isnan(pvals)) = [];
            pvals(pvals == 1) = [];

            %FDR.
            if ~isempty(pvals)
                [~,pcrit] = fdr_bh(pvals,0.05);
                m = cellfun(@median,CC(:,two));
                l = cellfun('length',CC(:,two));
                A(:,two) = Ap(:,two) < pcrit & m < 0 & l > critLaps;
            end       
        end 
        p.progress;
    end
    p.stop;
    
    graphData.A = A; 
    graphData.Ap = Ap; 
    graphData.lagMat = CC;
    graphData.null = null;
    graphData.closest = closest;
    graphData.Animal = md.Animal;
    graphData.Date = md.Date;
    graphData.Session = md.Session;
    
    save('Graphv4.mat','graphData','-v7.3');
end