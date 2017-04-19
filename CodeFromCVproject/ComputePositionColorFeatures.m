function [features, featWeights] = ComputePositionColorFeatures(img, sOpts)
% Compute a feature vector of colors and positions for all pixels in the
% image. For each pixel in the image we compute a feature vector
% (r, g, b, x, y) where (r, g, b) is the color of the pixel and (x, y) is
% its position within the image.
%
% INPUT
% img - Array of image data of size h x w x 3.
%
% OUTPUT
% features - Array of computed features of size h x w x 5 where
%            features(i, j, :) is the feature vector for the pixel
%            img(i, j, :).

height = size(img, 1);
width = size(img, 2);
features = zeros(height, width, 5);

[colGrid, rowGrid] = meshgrid(1:width, 1:height);
features(:, :, 4) = 2*(colGrid - width/2) / width;
features(:, :, 5) = 2*(rowGrid - height/2) / height;
colorFeatures = ComputeColorFeatures(img);
features(:, :, 1:3) = 2*(colorFeatures - 256/2)/256;

featWeights(1:3) = sOpts.colorWeight; % color weights
featWeights(4:5) = sOpts.posWeight; % pos weights
end