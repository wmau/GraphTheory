function [propInterestingNeuronsinComp,propNotInterestingNeuronsinComp] = strongConn(A,ind)
%
%
%

%%
    [s,c] = graphconncomp(sparse(A),'directed',false);
    
    propInterestingNeuronsinComp = sum(c(ind)==1)/sum(ind);
    propNotInterestingNeuronsinComp = sum(c(~ind)==1)/sum(~ind); 
    
    figure(1);
    bar([propInterestingNeuronsinComp, propNotInterestingNeuronsinComp],0.5,...
    'facecolor','k'); 

    figure(2);
    bar([length(unique(c(ind))),length(unique(c(~ind)))],0.5,'facecolor','k');
end