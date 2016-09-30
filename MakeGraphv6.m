function MakeGraphv6(md)
%
%
%

%%
    cd(md.Location);
    
    load('TimeCells.mat','TodayTreadmillLog','T');
   
    try 
        load('Pos_align.mat','FT','aviFrame'); 
    catch
        load('FinalOutput.mat','FT');
        [~,~,~,FT,~,~,aviFrame] = AlignImagingToTracking(md.Pix2CM,FT,0); 
    end
    
    inds = TodayTreadmillLog.inds;
    inds = inds(find(TodayTreadmillLog.complete),:);        %Only completed runs. 
    inds(:,2) = inds(:,1) + 20*T-1;                         %Consistent length.
    
    nRuns = sum(TodayTreadmillLog.complete);                %Number of completed runs. 
    critLaps = 0.25*nRuns;
    
    %Preallocate connectivity matrix. 
    nNeurons = size(FT,1);
    Ap = nan(nNeurons); 
    A = false(nNeurons);
    
    %Build all the rasters.
    raster = cell(1,nNeurons); 
    for n=1:nNeurons
        raster{n} = buildRaster(inds,FT,n);    
    end
    
    %Only look at neurons active on the treadmill for more than critLaps.
    nLapsActive = cell2mat(cellfun(@(x) sum(any(x,2)), raster, 'unif',0));
    active = find(nLapsActive > critLaps);

%% Do cross-correlation.
    p = ProgressBar(length(active)); 
    for target=active
        for trigger=active
            if trigger~=target
                %Do cross correlation. 
                xcorr_by_laps(raster{trigger},raster{target},critLaps); 
            end
        end
    end
    
end