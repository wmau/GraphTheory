function A = MakeGraphv2(sessionStruct)
%
%
%

%%  
    path = sessionStruct.Location;
    load(fullfile(path,'Pos_align.mat'),'FT'); 
    
    %Useful variables. 
    [nNeurons,nFrames] = size(FT);
    dt = 0.05;                  %seconds.
    window = 0.8;               %seconds.
    nBins = window/dt;          
    [onset,~] = getFEpochs(FT); 
    null = randi([-16,16],1,100000);
    A = zeros(nNeurons); 
    
    p = ProgressBar(nNeurons);
    for n=1:nNeurons
        wBack = onset{n}-nBins; 
        wForward = onset{n}+nBins; 
        
        %Number of spiking events. 
        nEpochs = length(onset{n});
        
        corrDists = cell(nNeurons-1,1); 
        corrDists{n} = nan;
        
        for e=1:nEpochs
            b = wBack(e);
            f = wForward(e);
            
            %Neurons that fire within the window of neuron n. 
            coincident = find(cellfun(@any,cellfun(@(c) c>b & c<f, onset,'unif',0)));
            coincident(coincident==n) = [];             %Remove self-coincidence.
            
            for i=1:length(coincident)
                c = coincident(i);
                lags = b-onset{c};
                corrDists{c} = [corrDists{c}, lags(lags<nBins & lags>-nBins)];      
            end
            
        end
        
        for i=1:length(coincident)
            c = coincident(i);
            
            if ~isempty(corrDists{c})
                [h,pval] = kstest2(corrDists{c},null);
                A([n,c],[c,n]) = h;    
            end
        end
        
    p.progress;
    end
    p.stop;
    
end