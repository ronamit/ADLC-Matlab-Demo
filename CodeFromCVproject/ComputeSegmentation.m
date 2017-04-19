function segments = ComputeSegmentation(img, mAlpha, sOpts)
k = sOpts.k;

% Extract Feautres:
[features, featWeights] = ComputePositionColorFeatures(img, sOpts);
[nRows, nCols, nFeat] = size(features);
nPix = nRows*nCols;
features = reshape(features, [nPix, nFeat]);
vAlpha = mAlpha(:);
features = features(vAlpha); % Take only foreground pixels
 
% Normalize Features:
if sOpts.normalizeFeatures
    features = NormalizeFeatures(features, vAlpha);
end
% Multiply Feat by weights:
if sOpts.useFeatsWeighting
    features = bsxfun(@times, features, featWeights);
end


% Cast to single:
features = single(features);

% Run Clustering:
tic;
switch (sOpts.clusteringMethod)
    case 'kmeans'
        [idx,~] = KMeansClustering(features, k, 0);
       
    case 'kmeansMatlab'
        idx = kmeans(features, k, 'Replicates', 5);
 
    case 'HAC'
        visualize2D = false;
        idx = HAClustering(features, k, visualize2D);  
end
toc;

idxForAllPix = zeros(nPix, 1); % zero = background
idxForAllPix(vAlpha) = idx;
segments =  reshape(idxForAllPix, [nRows,nCols]);
end

