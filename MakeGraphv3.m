function MakeGraphv3(md)
%
%
%

%% Load traces and align to imaging. 
    path = md.Location;
    cd(path);
    try 
        load(fullfile(path,'Pos_align.mat'),'FT','aviFrame'); 
    catch
        load(fullfile(path,'T2output.mat'),'FT');
        [~,~,~,FT,~,~,aviFrame] = AlignImagingtoTracking(md.Pix2CM,FT,0); 
    end

%% Setup. 
    %Find treadmill run indices. 
    load(fullfile(path,'TimeCells.mat'),'TodayTreadmillLog');
    inds = getTreadmillEpochs(TodayTreadmillLog,aviFrame); 
    inds = inds(find(TodayTreadmillLog.complete),:);  %Only completed runs. 
    nLaps = sum(TodayTreadmillLog.complete); 
    
    dt = 0.05;              %Bin size, seconds. 
    window = 10;            %Window of interest, seconds. 
    nBins = window/dt; 
        
    %Preallocate connectivity matrix. 
    nNeurons = size(FT,1);
    
    %% Construct graph. 
    lagMat = cell(nNeurons); 
    
    %For each lap...
    p = ProgressBar(nLaps);

    for l=1:nLaps
        %Get the onset times of each neuron. 
        onset = getFEpochs(FT(:,inds(l,1):inds(l,2)));
        
        %For each neuron...
        for n=1:nNeurons      
            %Number of calcium events in this neuron on this lap. 
            nEpochs = length(onset{n}); 
            
            %For each calcium event...
            for e=1:nEpochs
                coincidentNeurons = find(cell2mat(cellfun(@any,onset,'unif',0)));
                coincidentNeurons(coincidentNeurons==n) = []; 

        %For each other neuron...
                for c=coincidentNeurons'
                    %Find the interval between neuron n and neuron c.
                    lags = onset{n}(e)-onset{c};
 
                    lagMat{n,c} = [lagMat{n,c}, max(lags(lags>-nBins & lags<0))./20];           
                end    
            end
        end 
        p.progress;
    end

    graphDatav3.lagMat = lagMat;
    
    save('Graph.mat','graphDatav3','-v7.3');
end