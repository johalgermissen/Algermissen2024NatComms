function [p] = permutation_test(x, y, nIter)

% [p] = permutation_test(x, y, nIter)
%
% Simply permutation version of a one-sided (x > y) paired-samples t-test.
% 
% INPUTS:
% x, y          = numeric vectors of equal length that will be used for
%               permutation. Hypothesis x > y is tested.
% nIter         = numeric scalar, number permutations (default: 10000).
%
% OUTPUTS:
% p             = p-value (# samples in permutation distribution more
% extreme than empirical value).
%
% EEG/fMRI STUDY, DONDERS INSTITUTE, NIJMEGEN.
% J. Algermissen, 2018-2023.
% Should work in Matlab 2018b.

% we are here:
% cd /project/3017042.02/Analyses/EEG_Scripts/CueLockedAnalyses/CueLocked_Grouplevel/

% ----------------------------------------------------------------------- %
%% Complete settings:

if nargin < 3
    nIter = 10000;
end

fprintf('Perform permutation test with %d iterations\n', nIter);

if length(x) ~= length(y)
    error('Error: x and y of different length')
end

% ----------------------------------------------------------------------- %
%% Settings:

nS          = length(x); % number of samples in vectors
dif         = x - y; % difference vector of x and y
testVal     = nanmean(dif) / nanstd(dif); % Empirical test statistic (here: Cohen's d)
permDist    = nan(nIter, 1); % initialize permutation distribution

% ----------------------------------------------------------------------- %
%% Loop over permutations:

for i = 1:nIter

    % Draw value from uniform distribution between 0 and 1, threshold at
    % 0.5 into 0 and 1, -0.5 so values become -0.5 and +0.5, times 2 so
    % values become -1 and +1
    % NOTE: -1 and +1 not neccessarily in 50:50 fraction
    
    sign        = 2*((rand(nS, 1) > 0.5) - .5); % vectors of signs with -1 or 1
    testVec     = (dif).* sign; % multiply difference between x and y with sign
    permDist(i) = nanmean(testVec) / nanstd(testVec); % just take mean, divide by std (so Cohen's d), store in permutation distribution
    
end

% ----------------------------------------------------------------------- %
%% Compute p-value:

p = sum(permDist > testVal) / length(permDist); % number samples in permutation distribution that are more extreme that empirical test statistic

fprintf('Permutation test: p = %.03f\n', p);

end % END OF FUNCTION.