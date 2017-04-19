 clear;
 clc;
 close all;
 set(0, 'DefaultFigureWindowStyle', 'docked')
addpath('CodeFromCVproject');

imagePath = 'Images/manual_018_2eaf33263cf5.jpg';
% imagePath = 'Images/manual_006_aa77fc74890d.jpg';
% imagePath = 'Images/manual_011_284064c2688f.jpg';


colorImage = imread(imagePath);

I = rgb2gray(colorImage);

% Detect MSER regions.
[mserRegions, mserConnComp] = detectMSERFeatures(I, ...
    'RegionAreaRange',[200 8000],'ThresholdDelta',4);

figure
imshow(I, 'InitialMagnification', 'fit')
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions')
hold off

% Use regionprops to measure MSER properties
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

% Compute the aspect ratio using bounding box data.
bbox = vertcat(mserStats.BoundingBox);
w = bbox(:,3);
h = bbox(:,4);
aspectRatio = w./h;

% Threshold the data to determine which regions to remove. These thresholds
% may need to be tuned for other images.
filterIdx = (aspectRatio' < 0.8) & (aspectRatio' > 1.2) ;
filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
filterIdx = filterIdx | [mserStats.Solidity] < .3;
filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

% Remove regions
mserStats(filterIdx) = [];
mserRegions(filterIdx) = [];

% Show remaining regions
figure
imshow(I, 'InitialMagnification', 'fit')
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Geometric Properties')
hold off


% Get bounding boxes for all the regions
bboxes = vertcat(mserStats.BoundingBox);

% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

% Expand the bounding boxes by a small amount.
expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;

% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

% Show the expanded bounding boxes
expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
IExpandedBBoxes = insertShape(colorImage,'Rectangle',expandedBBoxes,'LineWidth',1);

figure
imshow(IExpandedBBoxes, 'InitialMagnification', 'fit')
title('Expanded Bounding Boxes Text')

% Compute the overlap ratio
overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

% Set the overlap ratio between a bounding box and itself to zero to
% simplify the graph representation.
n = size(overlapRatio,1);
overlapRatio(1:n+1:n^2) = 0;

% Create the graph
g = graph(overlapRatio);

% Find the connected text regions within the graph
componentIndices = conncomp(g);

% Merge the boxes based on the minimum and maximum dimensions.
xmin = accumarray(componentIndices', xmin, [], @min);
ymin = accumarray(componentIndices', ymin, [], @min);
xmax = accumarray(componentIndices', xmax, [], @max);
ymax = accumarray(componentIndices', ymax, [], @max);

% Compose the merged bounding boxes using the [x y width height] format.
textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

% Remove bounding boxes that only contain one text region
numRegionsInGroup = histcounts(componentIndices);
textBBoxes(numRegionsInGroup == 1, :) = [];

% Show the final text detection result.
ITextRegion = insertShape(colorImage, 'Rectangle', textBBoxes,'LineWidth',1);

figure
imshow(ITextRegion, 'InitialMagnification', 'fit')
title('Detected Blob')

%

sOpts.clusteringMethod = 'kmeansMatlab';  % 'HAC' / 'kmeans' / 'kmeansMatlab'
% Whether or not to normalize features before clustering.
sOpts.normalizeFeatures = true; % true / false
sOpts.useFeatsWeighting = true;
sOpts.colorWeight = 1; % color features weights
sOpts.posWeight = 1; % pos features weights
sOpts.k = 2;

 sOpts.backgroundMargin = 15; % pixels
sOpts.foregroundExtraMargin = 6; % pixels (positive or negative)
 sOpts.firmBgOusideBox = true; % true
  sOpts.maxSeSize = 0; % For morpholical improvement (0 = disable)
  
 sOpts.selectObjSegmentMethod =  'FewestPixels'; %  'FewestPixels' / 'UserInterface'
 sOpts.MinPixForObj = 30;
 
% sOpts.k = 3;
% [binIm, grayScaleIm] =  BinaraizeImage(colorImage, textBBoxes, sOpts);


[binIm, grayScaleIm] =  TwoStageSegmenter(colorImage, textBBoxes, sOpts);


figure
imshow(binIm, 'InitialMagnification', 'fit')
title('Binaraized Image');

% figure;
% se = strel('disk', 2);
% bimImMorphed= imopen(binIm,se);
% imshow(bimImMorphed, 'InitialMagnification', 'fit')
% title('Binaraized Image after morpholocial operations');


% Step 5: Recognize Detected Text Using OCR
ocrtxt = ocr(1 - binIm);
[ocrtxt.Text]

save('binIm', 'binIm')
save('grayScaleIm', 'grayScaleIm');