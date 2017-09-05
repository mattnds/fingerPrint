%Promt for image name
promt = 'Enter the image name: ';
image_name = input(promt,'s');

%This will use the function im2bw
binaryImage = im2bw(imread(image_name));
figure;
imshow(binaryImage);
title('Binary Image');

%inverse the image
binaryImage = ~binaryImage;

%Then set to a set size do remove outer boundaries and display
binaryImage = imcrop(binaryImage,[84.5 0.5 239 374]);

figure;
imshow(binaryImage);
title('Inversed Binary Image');

%Skeletonize the image
skeletonized = ~bwmorph(binaryImage,'thin',Inf);
figure;
imshow(skeletonized);
title('Skeletonized Image');

%Here we will do our minutiae extraction [variables...]
s = size(skeletonized); %get matrix size of image


%create template..
r = s(1)+2; %get number rows of new image
c = s(2)+2; %get number of columns
double tempMatrix(r,c); %crete a temporary matrix matrix of size rxc
tempMatrix = zeros(r,c); %fill tempMatrix with zeros
bifurcation = zeros(r,c); %duplicate tempMatrix into bifurcation matrix to find x,y locaitons
ridge = zeros(r,c); %duplicate tempMatrix into ridge matrix to find x,y locaitons
tempMatrix((2): (end-1), (2): (end-1)) = skeletonized(:,:); %fill tempMatrix with skeletonized matrix


%loops through tempMatrix and stores x and y values of the sum of neighbors
%needed a nested for loop
n = 1; 
for x = (n + 1 + 15): (s(1) + n - 15) %rows first and last 15 removed
    for y = (n + 1 + 15): (s(2) + n - 15) %columns first and last 15 removed
        a = 1;
        for k = x-n: x+n 
            b = 1;
            for l = y-n: y+n
                neighborsMatrix(a,b) = tempMatrix(k,l);
                b = b+1;
            end
            a = a+1;
        end;
         if(neighborsMatrix(2,2) == 0)
            ridge(x, y) = sum(sum(~neighborsMatrix)); %check for ridge and store x,y sum will be 2
            bifurcation(x, y) = sum(sum(~neighborsMatrix)); %check for bifurcation and store x,y sum will be 4
         end
    end;
end;

%find all x and y coordinates where the sum of 8 local neighbors is 2 and 4
[ridgeXValue, ridgeYValue] = find(ridge == 2);
[bifurcationXValue, bifurcationYValue] = find(bifurcation == 4);

%to show the final image. fill with 1's
outImg = zeros(r,c,3);
outImg(:,:,1) = tempMatrix .* 1;
outImg(:,:,2) = tempMatrix .* 1;
outImg(:,:,3) = tempMatrix .* 1;

%now we check where the sum will be 2 or 4. remember a ridge currently looks
%like this:
%[1 1 ; 1 1 ; 1 1]
%and a bifurcation looks like this:
%[3 3 3; 3 3 3; 3 3 3]

%go through an image(for loop) and place a 0 where there is a sum of 1 for
%a bifurcation
for i = 1:length(ridgeXValue) %loop through max size
    outImg((ridgeXValue(i) - 3): (ridgeXValue(i) + 3), (ridgeYValue(i) - 3), 2:3) = 0; 
    outImg((ridgeXValue(i) - 3): (ridgeXValue(i) + 3), (ridgeYValue(i) + 3), 2:3) = 0;
    outImg((ridgeXValue(i) - 3), (ridgeYValue(i) - 3): (ridgeYValue(i) + 3), 2:3) = 0;
    outImg((ridgeXValue(i) + 3), (ridgeYValue(i) - 3): (ridgeYValue(i) + 3), 2:3) = 0;
end

%go through an image(for loop) and place a 0 where there is a sum of 3 for
%a bifurcation
for i = 1:length(bifurcationXValue)
    outImg((bifurcationXValue(i) - 3): (bifurcationXValue(i) + 3), (bifurcationYValue(i) - 3), 1:2) = 0;
    outImg((bifurcationXValue(i) - 3): (bifurcationXValue(i) + 3), (bifurcationYValue(i) + 3), 1:2) = 0;
    outImg((bifurcationXValue(i) - 3), (bifurcationYValue(i) - 3): (bifurcationYValue(i) + 3), 1:2) = 0;
    outImg((bifurcationXValue(i) + 3), (bifurcationYValue(i) - 3): (bifurcationYValue(i) + 3), 1:2) = 0;
end

%Display result
figure;
imshow(outImg);
title('Final image');
