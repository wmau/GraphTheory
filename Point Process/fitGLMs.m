clear all;

% Load simulated data
load('ProcOut.mat','FT');   
X = FT'; 

% Dimension of input data (L: length, N: number of neurons)
[L,N] = size(X);
orders = [1:3];
bhat = cell(max(orders),N);

% To fit GLM models with different history orders
p = ProgressBar(N);
for neuron = 1:N                            % neuron
    parfor ht = orders                            % history
        bhat{ht,neuron} = glmtrial(X,neuron,ht,1);
    end
    p.progress;
end
p.stop;

LLK = nan(max(orders),N);
aic = LLK; 
% To select a model order, calculate AIC
p = ProgressBar(N);
for neuron = 1:N
    for ht = orders
        LLK(ht,neuron) = log_likelihood_win(bhat{ht,neuron},X,ht,neuron,1); % Log-likelihood
        aic(ht,neuron) = -2*LLK(ht,neuron) + 2*(N*ht/2 + 1);                % AIC
    end
    p.progress;
end
p.stop;

% To plot AIC 
% for neuron = 1:N
%     figure(neuron);
%     plot(aic(2:2:10,neuron));
% end

% Save results
save('GLMFit','bhat','aic','LLK');

% Identify Granger causality
% CausalTest;