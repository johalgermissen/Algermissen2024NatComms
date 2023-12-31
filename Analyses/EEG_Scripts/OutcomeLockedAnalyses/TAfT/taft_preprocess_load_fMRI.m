function X = taft_preprocess_load_fMRI(job)

% X = taft_preprocess_load_fMRI(job)
% 
% Calls function for fitting HRF amplitude, reshapes into design matrix.
% 
% INPUTS:
% job           = structure with settings for creating TAfT object, specifically:
% .goodTrlIdxfMRI= numeric vector, indices of trials to include; to be applied to fMRI data.
% .subID        = numeric scalar, subject ID.
%
% OUTPUTS:
% X             = a 2D (trials x fMRI regressor) design matrix.
%
% EEG/fMRI STUDY, DONDERS INSTITUTE, NIJMEGEN.
% J. Algermissen, 2018-2023.
% Adapted from Tobias Hauser (https://github.com/tuhauser/TAfT).
% Should work in Matlab 2018b.

% we are here:
% cd /project/3017042.02/Analyses/EEG_Scripts/OutcomeLockedAnalyses/TAfT/

fprintf('Subject %03d: Concatenate blocks, reject bad trials, demean regressors, combine into design matrix\n', ...
    job.subID);

% ----------------------------------------------------------------------- %
%% Estimate trial-by-trial HRF amplitude from raw fMRI data:

if isfield(job, 'ROIs') % if any fMRI ROIs specified
        
    out  = taft_preprocess_wrapper_upsample_fit(job);
    % out is a cell with name and trial-by-trial HRF amplitude per ROI per
    % block.
        
    % ------------------------------------------------------------------- %
    %% Reshape into design matrix:

    X = []; % initialize X

    % Loop over ROIs:
    for iROI = 1:length(out.ROIs)  

        % 1) Concatenate blocks:
        betaVector  = cat(2, out.ROIs{iROI}.ROIdef{:});
        % plot(betaVector)
        % hist(betaVector) % quite normal

        % 2) Reject bad trials:
        betaVector  = betaVector(job.goodTrlIdxfMRI); % created when loading EEG data.

        % 3) Demean regressor (entire subject):
        betaVector  = betaVector - nanmean(betaVector);

        % 4) Combine betas from different ROIs into one design matrix:
        X(:, iROI)  = betaVector; % trials in rows, ROIs in columns

    end
    
% ----------------------------------------------------------------------- %
else % if no fMRI ROIs specified:
    
    warning('No fMRI ROIs specified'); 
    X = [];
    
end % end isfield

end % END OF FUNCTION.