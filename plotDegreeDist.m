function plotDegreeDist(A)
%plotDegreeDist(A)
%
%   Plots the degree distribution of an adjacency matrix. 
%
%   INPUT
%       A: Adjacency matrix. 
%
%   OUTPUTS
%       Histogram and loglog plot of degree distribution. 
%

%% Plot degree distribution. 
    %Useful parameters.
    nBins = 40;

    %Get degrees for each node. 
    d = degrees(A); 
    
    %Plot histogram. 
    figure;
    histogram(d,nBins,'normalization','probability','facecolor','k'); 
        xlabel('Degree'); ylabel('Proportion'); 
        set(gca,'tickdir','out');

    %Loglog plot. 
    [n,bins] = hist(d,nBins); 
    figure;
    plot(log(bins),log(n),'ko'); 
        xlabel('Log Degree'); ylabel('Log Count'); 
        set(gca,'tickdir','out');
end
