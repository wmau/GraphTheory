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
    A = zeros(nNeurons); 
    Ap = zeros(nNeurons); 
    B = 200;
    
%% Construct graph. 
    lagMat = cell(nNeurons); 
    
    %Null distribution for comparing empirical lags. 
    null = cell(nNeurons);
    
    %For each lap...
    p = ProgressBar(nLaps);
    for l=1:nLaps
        %Get the onset times of each neuron. 
        onset = getFEpochs(FT(:,inds(l,1):inds(l,2)));
        
        %For each neuron...
        for n=1:nNeurons
            %Look at onset +/- window. 
            wBack = onset{n}-nBins;
            wForward = onset{n}+nBins; 
            
            %Number of calcium events in this neuron on this lap. 
            nEpochs = length(onset{n}); 
            
            %For each calcium event...
            for e=1:nEpochs
                b = wBack(e);       %Index of beginning of epoch minus lag. 
                f = wForward(e);    %Index of end of epoch plus lag. 
                
                %Other neurons that fire within the window of neuron n. 
                coincidentNeurons = find(cellfun(@any,cellfun(@(c) c>b & c<f, onset,'unif',0)));
                coincidentNeurons(coincidentNeurons==n) = [];             %Remove self-coincidence.
                
                %For each other neuron...
                for c=coincidentNeurons'
                    %Find the interval between neuron n and neuron c.
                    lags = b+nBins-onset{c};
                    lagMat{n,c} = [lagMat{n,c}, lags(lags<nBins & lags>-nBins)];
                    
                    for nn=1:B
                        %Shuffle traces of neuron c in time then find
                        %onset. Append a 0 to the end of the vector being
                        %shuffled to prevent connecting transients at the
                        %end and beginning of the epoch.
                        shuffledOnset = getFEpochs(circshift(...
                            [FT(c,inds(l,1):inds(l,2)) 0],...
                            [0,randi([0,200])]));
                        
                        %Circularly permuting sometimes introduces new
                        %epoch. Take the same number as the original.
                        shuffledOnset = shuffledOnset{1}(1:length(onset{c}));                       
                                                         
                        %Lag between neuron n spike and neuron c spike
                        %(shuffled).
                        nullLag = b+nBins-shuffledOnset;
                        null{n,c} = [null{n,c}, nullLag(nullLag<nBins & nullLag>-nBins)];
                    end
                   
                end
            end
        end         
        p.progress;
    end
    p.stop;
    
    %Perform pairwise comparisons between lag distributions for each neuron
    %(in both directions). Convention: row connects to colum, so nn should
    %fire first and lag between nn and cc should be negative. 
    alpha = 0.05/(nNeurons-1);
    p = ProgressBar(nNeurons);
    for nn=1:nNeurons
        for cc=1:nNeurons
            if ~isempty(lagMat{nn,cc}) && ...
                    length(lagMat{nn,cc}) > 3 && ...
                    mean(lagMat{nn,cc}) < 0
                [h,pval] = kstest2(lagMat{nn,cc},null{nn,cc},'alpha',alpha);
                
                Ap(nn,cc) = pval; 
                A(nn,cc) = h;
            end
        end
        p.progress;
    end
    p.stop;
    
    graphData.A = A; 
    graphData.Ap = Ap; 
    graphData.null =    cellfun(@(x) x./20, null,'unif',0);
    graphData.lagMat =  cellfun(@(x) x./20, lagMat,'unif',0); 
    
    save('Graph.mat','graphData','-v7.3');
    
end