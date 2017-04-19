
clear;
clc;
close all;

load('binIm.mat');  im = binIm;
% load('grayScaleIm.mat'); im = grayScaleIm;

imshow(im)

sProp = regionprops(im > 0, 'BoundingBox');
bboxes = sProp.BoundingBox;

% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

cropIm = im(floor(bboxes(2)):ceil(bboxes(2) + bboxes(4) - 1),...
    floor(bboxes(1)):ceil(bboxes(1) + bboxes(3) - 1), :);

imshow(cropIm)

rIm = imresize(cropIm, [28, 28]);

figure; imshow(rIm); title('Resized image 28x28');

imwrite(rIm, 'ImForClassifier.png')