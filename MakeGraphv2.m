function A = MakeGraphv2(sessionStruct)
%A = MakeGraphv2(sessionStruct)
%
%   This is a different method network inference. Here, I use a similar
%   algorithm as Bonifavi et al., 2009, where we look at temporal lags
%   between neuron responses. Going cell by cell, define windows around
%   its calcium events and look for other neurons that are active during
%   this window. Then look at the distribution of lags of these responses
%   relative to the first neuron. If they differ from a uniform null,
%   connect the nodes. 
%
%   INPUT
%       sessionStruct: MD entry. 
%
%   OUTPUT
%       A: Adjacency matrix. 
%

%% Load traces and align to imaging. 
    path = sessionStruct.Location;
    %load(fullfile(path,'Pos_align.mat'),'FT'); 
    load(fullfile(path,'ProcOut.mat'),'FT');
    [~,~,~,FT] = AlignImagingToTracking(0.15,FT);

%% Setup.
    %Useful variables. 
    [nNeurons,nFrames] = size(FT);
    dt = 0.05;                  %seconds.
    window = 0.8;               %seconds.
    nBins = window/dt;          
    [onset,~] = getFEpochs(FT);         %Get onset indices for calcium events. 
    null = randi([-16,16],1,100000);    %Null distribution for comparing empirical lags. 
    A = zeros(nNeurons); 

%% Construct the graph. 
    %For each neuron...
    p = ProgressBar(nNeurons);
    for n=1:nNeurons
        %Look at the onset plus/minus the lag.
        wBack = onset{n}-nBins; 
        wForward = onset{n}+nBins; 
        
        %Number of calcium events. 
        nEpochs = length(onset{n});
        
        %Preallocate. Reset for every neuron. Each cell entry represents
        %the lag at which another neuron was coincident within dt seconds. 
        corrDists = cell(nNeurons,1); 
        corrDists{n} = nan;
        
        %For each calcium event...
        for e=1:nEpochs
            b = wBack(e);       %Index of beginning of epoch, minus lag.
            f = wForward(e);    %Index of end of epoch, plus lag.
            
            %Neurons that fire within the window of neuron n. 
            coincident = find(cellfun(@any,cellfun(@(c) c>b & c<f, onset,'unif',0)));
            coincident(coincident==n) = [];             %Remove self-coincidence.
            
            %For each neuron that fires within the window...
            for i=1:length(coincident)
                c = coincident(i);
                lags = b+nBins-onset{c};
                corrDists{c} = [corrDists{c}, lags(lags<nBins & lags>-nBins)];      
            end
            
        end
        
        %For each neuron that was coincident...
        for i=1:length(coincident)
            c = coincident(i);
            
            if ~isempty(corrDists{c})
                %Test lag distribution against a uniform null. 
                h = kstest2(corrDists{c},null,'alpha',0.01);
                
                %Get the average lag to find whether it is positive or
                %negative. 
                avgLag = mean(corrDists{c}); 
                
                %Directed graph. 
                if avgLag>0
                    A(n,c) = h; 
                elseif avgLag<0
                    A(c,n) = h; 
                end
            end
        end
        
    p.progress;
    end
    p.stop;
    
end