clear; close all; clc; flag = 1;
% if flag = 1, plots all images, 0 dont plot (but the figure will be saved)

%% Data Loading
%Load both Images, covert to double and to grayscale
nimg1 = imread("../../Panorama/keble_a.jpg");
nimg2 = imread("../../Panorama/keble_b.jpg");
nimg3 = imread("../../Panorama/keble_c.jpg");

img1 = im2gray(im2double(imread("../../Panorama/keble_a.jpg")));
img2 = im2gray(im2double(imread("../../Panorama/keble_b.jpg")));
img3 = im2gray(im2double(imread("../../Panorama/keble_c.jpg")));

img1RGB = im2double(imread("../../Panorama/keble_a.jpg"));
img2RGB = im2double(imread("../../Panorama/keble_b.jpg"));
img3RGB = im2double(imread("../../Panorama/keble_c.jpg"));

%% Features related work
%Detect feature points (Can take advantage of the detectores putted into 
% evalution in Part1 of the assignment)
img1Points = detectORBFeatures(img1);
img2Points = detectORBFeatures(img2);
img3Points = detectORBFeatures(img3);

%Extract all features
[features1, vp1] = extractFeatures(img1, img1Points);
[features2, vp2] = extractFeatures(img2, img2Points);
[features3, vp3] = extractFeatures(img3, img3Points);

%Get matches between images
indexPair_12 = matchFeatures(features1, features2, "MatchThreshold",5);
indexPair_23 = matchFeatures(features2, features3, "MatchThreshold",5);

matchedPoints1  = vp1(indexPair_12(:,1));
matchedPoints21 = vp2(indexPair_12(:,2));
matchedPoints23 = vp2(indexPair_23(:,1));
matchedPoints3  = vp3(indexPair_23(:,2));


%Plot Matched Points
fig1 = figure;
showMatchedFeatures(img1RGB, img2RGB, matchedPoints1, matchedPoints21, 'montage');
title("Points matched between Img1 and Img2");
legend("Matched Points 1","Matched Points 2");
drawnow;

fig2 = figure;
showMatchedFeatures(img2RGB, img3RGB, matchedPoints23, matchedPoints3, 'montage');
title("Points Matched Between Img2 and Img3");
legend("Matched Points 2","Matched Points 3");
drawnow;

saveas(fig1, "../../Results/Panorama/Matched Points img1 and img2.png");
saveas(fig2, "../../Results/Panorama/Matched Points img2 and img3.png");
%% RANSAC
% RANSAC
%[H, nBest] = RANSAC(pts1, pts2, maxIterations, inlierThreshold)
[H12, nBest12] = RANSAC(matchedPoints1, matchedPoints21, 2000, 0.99);
[H32, nBest32] = RANSAC(matchedPoints3, matchedPoints23, 2000, 0.99);

%Check the "accuracy" of the homographic matrix
matchedPoints12 = [matchedPoints1.Location'; ones(1,length(matchedPoints1))];
matchedPoints32 = [matchedPoints3.Location'; ones(1,length(matchedPoints3))];

%Give the matched points in between img1->img2 and img3->img2 applies
%homographic matrix transformation
points12 = computeH(matchedPoints12, H12);
points32 = computeH(matchedPoints32, H32);

if flag == 1
    figPoints12Calculated = figure;
    scatter(points12(1,:), points12(2,:), 'r')
    hold on
    scatter(matchedPoints21.Location(:,1), matchedPoints21.Location(:,2), 'g')
    Pimg = imshow(img2RGB);
    uistack(Pimg,"bottom");
    legend("Calculated points","Matched points")
    drawnow;
    saveas(figPoints12Calculated, "../../Results/Panorama/points_1_to_2_calculated.png")

    figPoints32Calculated = figure;
    scatter(points32(1,:), points32(2,:), 'r')
    hold on
    scatter(matchedPoints23.Location(:,1), matchedPoints23.Location(:,2), 'g')
    Pimg = imshow(img2RGB);
    uistack(Pimg,"bottom");
    legend("Calculated points","Matched points")
    drawnow;
    saveas(figPoints32Calculated, "../../Results/Panorama/points_3_to_2_calculated.png");
end
%% Image Stitching

%[imgcomposed, displacement] = composeimgs(img1, img2, H)
% aplies H (warping transformation) to img2
[imgComposed1, displacement1] = composeimgs(nimg2, nimg1, H12);
[imgComposed2, displacement2] = composeimgsV2(nimg2, nimg3, H32);

if flag == 1
    figComposed1 = figure;
    imshow(imgComposed1);
    saveas(figComposed1,"../../Results/Panorama/ImageComposed1.png");

    figComposed2 = figure;
    imshow(imgComposed2);
    saveas(figComposed2,"../../Results/Panorama/ImageComposed2.png")
end
RemoveWhiteSpace([], 'file', "../../Results/Panorama/ImageComposed1.png");
RemoveWhiteSpace([], 'file', "../../Results/Panorama/ImageComposed2.png");

%% Here we go again
clc; clear; flag = 1;
nimg1 = imread("../../Results/Panorama/ImageComposed1.png");
nimg2 = imread("../../Results/Panorama/ImageComposed2.png");

img1 = im2gray(im2double(imread("../../Results/Panorama/ImageComposed1.png")));
img2 = im2gray(im2double(imread("../../Results/Panorama/ImageComposed2.png")));

img1RGB = im2double(imread("../../Results/Panorama/ImageComposed1.png"));
img2RGB = im2double(imread("../../Results/Panorama/ImageComposed2.png"));

img1Points = detectORBFeatures(img1);
img2Points = detectORBFeatures(img2);

[features1, vp1] = extractFeatures(img1, img1Points);
[features2, vp2] = extractFeatures(img2, img2Points);

indexPair = matchFeatures(features1, features2, "MatchThreshold",5);

matchedPoints1  = vp1(indexPair(:,1));
matchedPoints2  = vp2(indexPair(:,2));
if flag == 1
    fig1 = figure;
    showMatchedFeatures(img1RGB, img2RGB, matchedPoints1, matchedPoints2, 'montage');
    title("Points matched between ImgComposed1 and ImgComposed2");
    legend("Matched Points 1","Matched Points 2");
    drawnow;
    saveas(fig1, "../../Results/Panorama/Matched Points imgComposed1 and imgComposed2.png");
end
[H, nBest] = RANSAC(matchedPoints1, matchedPoints2, 2000, 0.99);

matchedPoints = [matchedPoints1.Location'; ones(1,length(matchedPoints1))];

points = computeH(matchedPoints, H);

if flag == 1
    figPoints12Calculated = figure;
    scatter(points(1,:), points(2,:), 'r')
    hold on
    scatter(matchedPoints2.Location(:,1), matchedPoints2.Location(:,2), 'g')
    Pimg = imshow(img2RGB);
    uistack(Pimg,"bottom");
    legend("Calculated points","Matched points")
    drawnow;
    saveas(figPoints12Calculated, "../../Results/Panorama/points_1Comp_to_2Comp_calculated.png")
end

[imgComposed, displacement] = composeimgs(nimg2, nimg1, H);
figComposed = figure;
imshow(imgComposed);
title("Max of the images");
saveas(figComposed,"../../Results/Panorama/FinalImageComposed.png");

RemoveWhiteSpace([], 'file', "../../Results/Panorama/FinalImageComposed.png");

input.canvas_color = 'black';  %'black'| 'white'
input.blackRange = 5;
input.whiteRange = 250;
input.showCropBoundingBox = 0;

croppedImage = panoramaCropper(input, imgComposed);
figCroppedImage = figure;
imshow(croppedImage);
title("Max of the images (cropped version)");
saveas(figCroppedImage,"../../Results/Panorama/FinalCroppedImageComposed.png");

