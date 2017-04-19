function [gmmModel0, gmmModel1, compNegLogProb0, compNegLogProb1] = UpdateGmmModels(gmmModel0, gmmModel1, zAll, vAlpha, nComponents0, nComponents1)
% UPDATE THE GAUSSIAN MIXTURE MODELS


optionsGmmFit = statset('MaxIter', 60, 'TolFun', 1e-3);
regulizeVal = 1e-3;

startAtPrevGmm = true;

% If GMM models have already been computed, use them aas a starting point:
if ~isempty(gmmModel0) && startAtPrevGmm
    try
        % Update:
        startModel0 = struct('mu',gmmModel0.mu,'Sigma',gmmModel0.Sigma,'ComponentProportion',gmmModel0.ComponentProportion);
        gmmModel0 = fitgmdist(zAll(~vAlpha, :), nComponents0, 'Start', startModel0, 'options',optionsGmmFit, 'RegularizationValue', regulizeVal, 'CovarianceType','full');
        
        startModel1 = struct('mu',gmmModel1.mu,'Sigma',gmmModel1.Sigma,'ComponentProportion',gmmModel1.ComponentProportion);
        gmmModel1 = fitgmdist(zAll(vAlpha, :), nComponents1, 'Start', startModel1, 'options',optionsGmmFit, 'RegularizationValue', regulizeVal, 'CovarianceType','full');
        
        computeNewModels = false;
        
    catch
        % in case of  il-coditined covarince error - comute new GMM  models
        computeNewModels = true;
    end
else
    computeNewModels = true;
end

% Init:
if computeNewModels
    disp('Estimating new GMM models');
    gmmModel0 = fitgmdist(zAll(~vAlpha, :), nComponents0, 'options',optionsGmmFit, 'RegularizationValue', regulizeVal, 'CovarianceType','full');
    gmmModel1 = fitgmdist(zAll(vAlpha, :), nComponents1, 'options',optionsGmmFit, 'RegularizationValue', regulizeVal, 'CovarianceType','full');
end



% Calculate probability of each pixel for association to each component:
[compNegLogProb0] = GetComponentProb(zAll, gmmModel0);
[compNegLogProb1] = GetComponentProb(zAll, gmmModel1);


end


function [compNegLogProb] = GetComponentProb(zAll, gmmModel)

nPixAll = size(zAll, 1);
nComponents = gmmModel.NumComponents;
compNegLogProb = zeros(nPixAll, nComponents);
for iComp = 1:nComponents
    
    mu = gmmModel.mu(iComp, :);
    sigma = gmmModel.Sigma(:, :, iComp);
    compWeight = gmmModel.ComponentProportion(iComp);
    zDist = zAll - repmat(mu, [nPixAll, 1]);
    compNegLogProb(:,iComp) = -log(compWeight) + 0.5*log(det(sigma)) + 0.5*sum((zDist/sigma).*zDist, 2);
end

end

