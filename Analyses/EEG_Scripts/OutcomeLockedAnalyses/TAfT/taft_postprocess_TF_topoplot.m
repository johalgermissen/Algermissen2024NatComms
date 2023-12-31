function taft_postprocess_TF_topoplot(job, dirs, Tvalues, iROI, startFreq, endFreq, startTime, endTime, steps, zlim, isSave)

% taft_postprocess_TF_topoplot(job, dirs, Tvalues, iROI, startFreq, endFreq, startTime, endTime, steps, zlim, isSave)
% 
% For fMRI-EEG regression weights for selected ROI, looping over frequency ranges, 
% plot a topoplot for given time window ranges (in subplots).
%
% INPUTS:
% job           = cell with necessary settings for timing settings and name
% of image file to be saved:
% .HRFtype      = string, whether to perform estimation of HRF amplitude for each trial separately ('trial') or in a GLM featuring all trials of a given block ('block').
% .layout       = string, cap to use for topoplots.
% .trialdur 	= numeric scalar, trial duration to use when epoching upsampled BOLD data in seconds (recommended by Hauser et al. 2015: 8 seconds).
% .regNames 	= cell, one or more string(s) of all regressors (fMRI and behavior) to include in design matrix plus selected trials.
% dirs          = cell, directories where to save image file:
% .topoplot     = string, directory where to save topoplots.
% Tvalues       = Fieldtrip object with t-value for each
%               channel/frequency/time bin in .powspctrm
% iROI          = numeric scalar, index of selected ROI (to retrieve correct name).
% startFreq     = vector, lower bounds of frequency ranges from where to start averaging.
% endFreq       = vector, upper bounds of frequency ranges where to stop averaging.
% startTime     = numeric scalar, time from where to start plotting.
% endTime       = numeric scalar, time where to stop plotting.
% steps         = numeric scalar, time steps for which to make separate plot.
% zlim          = vector of two numerics, limit for color axis (-zlim zlim) in units of T.
% isSave        = Boolean, save plot (true) or not (false).
% 
% OUTPUTS:
% none, just create plot.
%
% EEG/fMRI STUDY, DONDERS INSTITUTE, NIJMEGEN.
% J. Algermissen, 2018-2023.
% Adapted from Tobias Hauser (https://github.com/tuhauser/TAfT).
% Should work in Matlab 2018b.

% we are here:
% cd /project/3017042.02/Analyses/EEG_Scripts/OutcomeLockedAnalyses/TAfT/

% ----------------------------------------------------------------------- %
%% Complete settings:

if nargin < 4
    iROI        = 1;
    fprintf('No ROI specified -- use first ROI\n');
end
if nargin < 5
    startFreq   = [1 4 8 13];
    endFreq     = [4 8 13 33];
    fprintf('No frequency boundaries specified -- use standard bands\n');
end

if nargin < 7
    startTime   = 0.0;
    endTime     = 0.9;
    steps       = 0.1;
    fprintf('No timings specified -- use default startTime = %.1f,endTime = %.1f, steps = %.1f\n', ...
        startTime, endTime, steps);
end

if nargin < 10
    zlim        = 3; % in units of T
    fprintf('No zlim specified -- use default zlim = %d\n', zlim);
end

if nargin < 11
    isSave      = false;
    fprintf('Do not save plot by default\n');
end

% ----------------------------------------------------------------------- %
%% Topoplot settings:

fprintf('ROI %s: Create topoplot over time\n', char(job.regNames(iROI)));

nCol            = 5; % number of columns in subplot
fontSize        = 12; 

% ----------------------------------------------------------------------- %
%% Timing settings:

startTimeVec    = startTime:steps:endTime; % vector of start time for each subplot
endTimeVec      = (startTimeVec(1) + steps):steps:(startTimeVec(end) + steps);  % vector of end time for each subplot
nRow            = ceil(length(startTimeVec) ./ nCol); % number of rows following from bins

% ----------------------------------------------------------------------- %
%% Create topoplot:

for iFreq = 1:length(startFreq) % % loop over given frequency ranges
    
    selFreqs = [startFreq(iFreq) endFreq(iFreq)]; % select frequencies

    % ------------------------------------------------------------------- %
    %% Start plot:
    
    figure('units', 'normalized', 'outerposition', [0 0 1 1]); hold on % fullscreen
    
    for iPlot = 1:length(endTimeVec) % loop over given time windows
        
        subplot(nRow, ceil(length(endTimeVec) / nRow), iPlot);
        
        cfg         = []; 
        cfg.figure  = gcf; 
        cfg.ylim    = selFreqs; 
        cfg.zlim    = [-1*zlim 1*zlim]; 
        cfg.marker  = 'on'; 
        cfg.style   = 'straight';
        cfg.layout  = job.layout; 
        cfg.comment = 'no'; 
        cfg.xlim    = [startTimeVec(iPlot) endTimeVec(iPlot)];
    %    cfg.highlight = 'on'; cfg.highlightjob.channel = job.channels; cfg.highlightsymbol = 'o'; % highlight selected channels --> gets too small with multiple subplots
        cfg.colorbar    = 'no'; % want 'no', i.e. do it yourself % --> add externally
        
        ft_topoplotTFR(cfg, Tvalues);
        
        title(sprintf('%.2f to %.2f sec', ...
            startTimeVec(iPlot), endTimeVec(iPlot)), ...
            'fontsize', fontSize);
        
    end % end iPlot
    
    % ------------------------------------------------------------------- %
    %% Overall title:

    sgtitle(sprintf('Topoplot for ROI %s, frequencies %d - %d Hz, time window %.1f - %.1f sec.', ...
        char(job.regNames(iROI)), selFreqs(1), selFreqs(end), ...
        startTimeVec(1), endTimeVec(end)), 'fontsize', fontSize);

    fprintf('Finished topoplot\n');
    
    % ------------------------------------------------------------------- %
    %% Save:
    
    if isSave
       saveas(gcf,fullfile(dirs.topoplot, sprintf('Topoplot_TF_%s_%s_%dsec_%d-%dHz_%s-%sms.png', ...
           char(job.regNames(iROI)), job.HRFtype, job.trialdur, ...
           selFreqs(1), selFreqs(end), ...
           num2str(1000*startTimeVec(1)), num2str(1000*endTimeVec(end)))));
    end
    
end % end iFreq

end % END OF FUNCTION.