function [mAlpha, grayScaleIm] = BinaraizeImage(I, textBBoxes, sOpts)

% textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];


binIm = zeros([size(I, 1), size(I, 2)], 'uint8');

cropIm = I(floor(textBBoxes(2)):ceil(textBBoxes(2) + textBBoxes(4) - 1),...
    floor(textBBoxes(1)):ceil(textBBoxes(1) + textBBoxes(3) - 1), :);


figure; imshow(cropIm, 'InitialMagnification','fit');




% Run k-means to mark character pixels:
mAlpha = true([size(cropIm, 1), size(cropIm, 2)]);
[ mAlpha, grayScaleIm ] = RunSegmentationByFeatures( cropIm , mAlpha, sOpts);

% figure; imshow(mAlpha, []);

% Insert '0' in pixels not in text box:


% binIm(textBBoxes(1)
