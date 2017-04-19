function [ mAlpha, bbox] = GetUserMark( imData, inputType, msgStr)
%
%

[nRows, nCols, ~] = size(imData);
hFig = figure;
imshow(imData, 'InitialMagnification','fit');
switch (inputType)
    case  'BoundingBox'
        % a bounding box initialization
        gotValidInput = false;
        while ~gotValidInput
            title(msgStr);
            set(gca,'Units','pixels');
            ginput(1);
            p1=get(gca,'CurrentPoint');
            fr=rbbox; pause(0.01);
            p2=get(gca,'CurrentPoint');
            p=round([p1;p2]);
            xmin=min(p(:,1));xmax=max(p(:,1));
            ymin=min(p(:,2));ymax=max(p(:,2));
            xmin = max(xmin, 1);
            xmax = min(nCols, xmax);
            ymin = max(ymin, 1);
            ymax = min(nRows, ymax);
            
            save('LastUserBox', 'xmin',  'ymin',  'xmax',  'ymax'); % debug
            %           load('LastUserBox', 'xmin',  'ymin',  'xmax',  'ymax'); % debug
            
            mAlpha = false(nRows,nCols);
            mAlpha(ymin:ymax, xmin:xmax) = true;
            % Draw Box:
            bbox = [xmin ymin xmax ymax];
            
            line(bbox([1 3 3 1 1]),bbox([2 2 4 4 2]),'Color',[1 0 0],'LineWidth',1);
            drawnow;
            gotValidInput = (xmax > xmin) && (ymax > ymin);
            
        end
    case 'FreeHand'
        title('Draw closed contour around object');
        mAlpha = createMask(imfreehand(gca, 'Closed', true));
        bbox = [];
        
    case 'Polygon'
        title('Draw closed polygon around object');
        mAlpha = createMask(impoly(gca, 'Closed', true));
        bbox = [];
end


end

