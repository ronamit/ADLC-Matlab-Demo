function [mAlpha, grayScaleIm] = TwoStageSegmenter(im, blobBoxes, sOpts)

% Box format:
% box = [xmin ymin xmax-xmin+1 ymax-ymin+1];

binIm = zeros([size(im, 1), size(im, 2)], 'uint8');

% Define a larger crop around the blob, which include some background.


blobBoxes = blobBoxes + sOpts.foregroundExtraMargin * [-1, -1, +2, +2];
blobBoxes = CropToImSize(size(im), blobBoxes);

backgroundMargin = sOpts.backgroundMargin;
cropBox = blobBoxes + backgroundMargin * [-1, -1, +2, +2];
cropBox = CropToImSize(size(im), cropBox);

cropIm = im(cropBox(2):(cropBox(2) + cropBox(4) - 1),...
    cropBox(1):(cropBox(1) + cropBox(3) - 1), :);


% Show the crop and blob boundaries:
imForShow = insertShape(im, 'Rectangle', blobBoxes,'LineWidth',1, 'Color', 'y');
imForShow = insertShape(imForShow, 'Rectangle', cropBox,'LineWidth',1, 'Color', 'g');
figure; imshow(imForShow, 'InitialMagnification', 'fit'); title('crop and blob boundaries');


% Run GrabCut on the crop, with the initial object segment is the blob
% [mAlpha] = RunGrabCutWithUserInput(im);


blobInCropBox = [blobBoxes(1)-cropBox(1)+1 , blobBoxes(2)-cropBox(2)+1 , blobBoxes(3), blobBoxes(4)];

[mAlpha, foregroundIm] = RunGrabCut(cropIm, blobInCropBox, sOpts);

% Run K-Means with K=2 to separate the shape and the letter
% Run k-means to mark character pixels:
[ mAlpha, grayScaleIm ] = RunSegmentationByFeatures( cropIm, mAlpha, sOpts);

% figure; imshow(mAlpha, []);

% Insert '0' in pixels not in text box:


% binIm(textBBoxes(1)
