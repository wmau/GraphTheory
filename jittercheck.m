function [Aprime,propFailed] = jittercheck(A,R,FT)
%[Aprime,propFailed] = jittercheck(A,R,FT)
%   
%   Check the legitimacy of edges by jittering spikes. This function asks
%   for every neuron whether jittering its spike times yields any higher
%   correlation coefficients with the neurons it is supposedly correlated
%   with. 
%
%   INPUTS
%       A: Adjacency matrix from MakeGraph.
%
%       R: Correlation matrix from MakeGraph. 
%
%       FT: Output from TENASPIS. 
%
%   OUTPUTS
%       Aprime: Corrected adjacency matrix. Removed all edges that failed
%       the jitter test.
%
%       propFailed: Proportion of edges that failed the jitter test. 
%

%% 
    B = 1000; 
    Aprime = A; 
    [nNeurons,nFrames] = size(FT); 
    pBoot = cell(nNeurons,1); 
    nFailed = 0; 
  
    p = ProgressBar(nNeurons); 
    for thisNeuron=1:nNeurons     
        %Get the neuron indices with which this neuron is correlated. 
        corrNeurons = find(A(thisNeuron,:)); 
        nCorrNeurons = length(corrNeurons); 
        
        %Get the correlation coefficient. 
        empR = R(thisNeuron,corrNeurons); 
        
        %Preallocate shuffled distribution. 
        shuffR = nan(B,nCorrNeurons); 
        
        %Vector of jitters. 
        jitters = randsample(nFrames,B,true); 
        
        %Perform permutations.        
        parfor i=1:B
            FTshuff = circshift(FT(thisNeuron,:),[0,jitters(i)]);
            
            shuffR(i,:) = corr(FTshuff',FT(corrNeurons,:)');    
        end
        
        %P-value. 
        pval = sum(shuffR > repmat(empR,B,1))/B;
        pBoot{thisNeuron} = pval;
        
        %Unwire neurons that don't pass this jitter test. 
        Aprime(thisNeuron,corrNeurons(pval>0.05)) = 0; 
        Aprime(corrNeurons(pval>0.05),thisNeuron) = 0; 
        
        %Number of neurons that don't pass the jitter test. 
        nFailed = nFailed + sum(pval>0.05); 

        p.progress;
    end
    p.stop; 
    
    %Get proportion of neurons that fail the bootstrap test. 
    e = numedges(A); 
    propFailed = nFailed/e; 
    
    keyboard; 
    
end