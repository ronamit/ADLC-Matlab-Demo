function [mAlpha, foregroundIm] = RunGrabCut(imData, bbox, sOpts)


%% Parameters
gamma = 50; %50
betta = 1; % 0.3
nieghborhoodType =  '8-nieghborhood'; % '4-nieghborhood' /  '8-nieghborhood'
dataWeightType = 'TrueProb'; % 'MaxCompProb'  / 'TrueProb'
colorSpace = 'LAB';% 'RGB' \'LAB'
nComponents1 = 2; % 9
nComponents0 = 3; % 9
maxIter = 20;  % 20
minChangeRatio = 0.0001; %  0.0005 stop condition


firmBgOusideBox = sOpts.firmBgOusideBox;

% inputType = 'BoundingBox'; % 'BoundingBox' /  'FreeHand' / 'Polygon'

firmUserCorrect = true; % true

 
%% Pre-Process
% convert the pixel values single.
imData =  im2single(imData);

switch (colorSpace)
    case 'LAB'
        imDataS = rgb2lab(imData);
    case 'RGB'
        imDataS = imData;
end

[nRows, nCols, ~] = size(imDataS);
nPix = nRows*nCols;
zAll = 255 * reshape(imData, [nPix, 3]);

%% Get Input from User:
% msgStr = 'Draw a bounding box to specify the rough location of the foreground';
% [ mAlpha, bbox] = GetUserMark( imData, inputType, msgStr);
%% Algorithm Init
% INITIALIZE THE FOREGROUND & BACKGROUND GAUSSIAN MIXTURE MODEL (GMM)
gmmModel0 = [];
gmmModel1 =   [];

% initial foreground mark
mAlpha = false([size(imData, 1), size(imData, 2)]);
xmin = floor(bbox(:,1));
ymin = floor(bbox(:,2));
xmax = ceil(xmin + bbox(:,3) - 1);
ymax = ceil(ymin + bbox(:,4) - 1);
mAlpha(ymin:ymax, xmin:xmax) = true;
vAlphaInit =  mAlpha(:);

% Init Graph:
% Smoothnes Term Edges (Edges between neighbours):
nbEdges  = GetNeighborEdges(nRows, nCols, nieghborhoodType);
node1 = nbEdges(:,1);
node2 = nbEdges(:,2);

% Smoothnes Term Weights:
nbSqrDist = sum((zAll(node1, :) - zAll(node2, :)).^2, 2);
nbWeight =  gamma .* exp(-betta *  nbSqrDist / mean(nbSqrDist));
V = sparse(node1, node2, double(nbWeight), nPix, nPix, length(node1));

% Data Term Edges:
sEdges = [(1:nPix)', 1*ones(nPix,1)]; %  source (index 1) =  Foreground (alpha1)
tEdges = [(1:nPix)', 2*ones(nPix,1)]; %  target (index 2) =  Background (alpha0)

mCorrectFore = []; mCorrectBack = [];
%% Algorithm Iterations:

hFig = figure;
maxIterCurr = maxIter;
stopCond = false;
iIter = 1;
tic;
while ~stopCond
    disp(['Iter: ', num2str(iIter)]);
    
    % UPDATE THE GAUSSIAN MIXTURE MODELS
    [gmmModel0, gmmModel1, compNegLogProb0, compNegLogProb1] = ...
        UpdateGmmModels(gmmModel0, gmmModel1, zAll,  mAlpha(:), nComponents0, nComponents1);
    
    % Data Term Weights:
    switch  (dataWeightType)
        case 'MaxCompProb'
            sWeights = min(compNegLogProb1, [], 2);
            tWeights = min(compNegLogProb0, [], 2);

        case  'TrueProb'
            sWeights = -log(sum(exp(-compNegLogProb1), 2));
            tWeights = -log(sum(exp(-compNegLogProb0), 2));            
            
    end
    % Modify Data Term Weights:
    if firmBgOusideBox
        sWeights(~vAlphaInit) = max(sWeights(vAlphaInit));  % Force background outside the original box
        tWeights(~vAlphaInit) = min(tWeights(vAlphaInit));  % Force background outside the original box
    end
    
    if firmUserCorrect && ~isempty(mCorrectFore)
         % Force foreground at the user correction
        sWeights(mCorrectFore) = min(sWeights(~mCorrectFore)); 
        tWeights(mCorrectFore) = max(tWeights(~mCorrectFore));  
    end
    if firmUserCorrect && ~isempty(mCorrectBack)
        % Force background at the user correction
        sWeights(mCorrectBack) = max(sWeights(~mCorrectBack));  
        tWeights(mCorrectBack) = min(tWeights(~mCorrectBack));  
    end
    
    
    U = sparse([sEdges(:, 1); tEdges(:,1)],[sEdges(:, 2); tEdges(:,2)], double([sWeights; tWeights]));
    
    % MAX-FLOW/MIN-CUT ENERGY MINIMIZATION:
    vAlphaPrev =  mAlpha(:);
    [~,labels] = maxflow(V, U);
    vAlpha = (labels == 1);
    mAlpha = reshape(vAlpha, [nRows, nCols]);
    
    % Show Current Foreground:
    figure(hFig);

    imshow(repmat(mAlpha,[1,1,3]).*imData, 'InitialMagnification','fit');
    title(['Foreground Image  - Iter: ', num2str(iIter)]);
    drawnow;
    
    % Check Stop Condition:
    iIter = iIter + 1;
    minChangedPixNum = minChangeRatio * nPix;
    stopCond =  (iIter > maxIterCurr) || (sum(vAlphaPrev~= mAlpha(:)) < minChangedPixNum) || all(~mAlpha(:)) || all(mAlpha(:));
    
%     if stopCond && interactiveUserCorrects
%         % Suggest user corrections after automatic iterations stopped
%         % If the user make changes - continue with iterarions
%         
%         % Morpholigical improvement operations, before show to user 
%         [ mAlpha ] = MorphologicalImprovent( mAlpha, maxSeSize );                        
%         toc;
%         [mAlpha, stopCond, mCorrectFore, mCorrectBack] = UserCorrections(mAlpha,imData, mCorrectFore, mCorrectBack, correctMethod);       
%         if ~stopCond
%             % User Made Corrections - so add extra iterations           
%             maxIterCurr = maxIterCurr +  correctExtraIterNum;
%         end
%     end
    
    if stopCond
        break;
    end
    
end

% Morpholigical Improvment Operations:
[ mAlpha ] = MorphologicalImprovent( mAlpha, sOpts);

% figure;
% subplot(1,2,1);
% imshow(imData, 'InitialMagnification','fit'); title('User Input');
% if ~isempty(bbox)
%     line(bbox([1 3 3 1 1]),bbox([2 2 4 4 2]),'Color',[1 0 0],'LineWidth',1);
% end
% subplot(1,2,2);

figure;
foregroundIm = repmat(mAlpha,[1,1,3]).*imData;
imshow(foregroundIm, 'InitialMagnification','fit'); title('Final Foreground Image');


end