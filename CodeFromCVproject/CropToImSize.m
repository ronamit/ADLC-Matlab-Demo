function bbox = CropToImSize(imSize, bbox)
% box = [xmin ymin xmax-xmin+1 ymax-ymin+1];

xmin = floor(bbox(1));
ymin = floor(bbox(2));
xmax =  ceil(bbox(3) + bbox(1) - 1);
ymax =  ceil(bbox(4) + bbox(2) - 1);

xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, imSize(2));
ymax = min(ymax, imSize(1));

 bbox = [xmin ymin xmax-xmin+1 ymax-ymin+1];





end