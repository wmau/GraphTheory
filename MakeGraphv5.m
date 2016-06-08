function MakeGraphv5(md)
%
%
%

%% 
    cd(md.Location); 
    
    load('TimeCells.mat','T','TodayTreadmillLog'); 
    load('Pos_align.mat','FT');
    load('ProcOut.mat','NumNeurons');
    complete = TodayTreadmillLog.complete;
    inds = TodayTreadmillLog.inds; 
    
    %Get treadmill run indices. 
    inds = inds(find(complete),:);  %Only completed runs. 
    inds(:,2) = inds(:,1) + 20*T-1; %Consistent length.   
    nLaps = sum(complete); 
    
    %Build raster for each cell. 
    rasters = cell(1,NumNeurons);
    for i=1:NumNeurons
        rasters{i} = buildRaster(inds,FT,i);
    end
        
    %Only look at active neurons. 
    active = find(cellfun(@(x) any(x(:)), rasters));
    
    closest = cell(NumNeurons);
    CC = cell(NumNeurons);
    intervalSpread = nan(NumNeurons);
    ratio = nan(NumNeurons);
    Ap = nan(NumNeurons); 
    B = 1000;
    p = ProgressBar(length(active));
    for two=active
        for one=active
            if one~=two
                [immediateRaster,closest{one,two}] = stripRaster(rasters{one},rasters{two});
    
                %Spread of cell-to-cell interval distribution. 
                intervalSpread(one,two) = mad(closest{one,two},1);
                
                %Only look at laps where both neurons were active. 
                bothActiveLaps = find(any(immediateRaster,2)); 
                TMalignedOnsets = [];
                for l=bothActiveLaps
                    %Get the onset times of each neuron. 
                    TMalignedOnsets = [TMalignedOnsets find(rasters{two}(l,:))];     
                end

                %Divide by frame rate and divide by frame rate. 
                TMalignedOnsets = TMalignedOnsets./20;

                %Spread of responses relative to treadmill start. 
                treadmillSpread = mad(TMalignedOnsets,1);

                %Ratio between cell-to-cell vs cell-to-treadmill.
                ratio(one,two) = intervalSpread(one,two) / treadmillSpread;
                
                null = zeros(1,B); 
                parfor i=1:B
                    shuffled = rasters{one}(randperm(nLaps),:);
                    [~,dB] = stripRaster(shuffled,rasters{two});
                    dB = dB./20;
                    dBSpread = mad(dB,1);
                    null(i) = dBSpread./treadmillSpread;        
                end
                
                %p-value. 
                Ap(one,two) = sum(ratio(one,two) > null) / B; 
                
                %Cross-correlation.
                CC{one,two} = lapCC(rasters{one},rasters{two},0);
            end
        end
        
        p.progress;
    end
    p.stop;

    keyboard;
end