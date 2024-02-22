function [H, nBest] = RANSAC(pts1, pts2, maxIterations, inlierThreshold)

nBest = 0;  % Max number of inliers
H = [];     % Homography Matrix

pts1 = [pts1.Location'; ones(1, length(pts1))];
pts2 = [pts2.Location'; ones(1, length(pts2))];

numPts = length(pts1);

for i = 1:maxIterations
    % Randomly select 4 feature pairs
    idx = randperm(numPts, 4);
    samplePts1 = pts1(:, idx);
    samplePts2 = pts2(:, idx);

    % Compute the homography for the random subset
    Hi = ComputeHomography(samplePts1(1:2, :)', samplePts2(1:2, :)');

    % Calculate the correspondent points of Image 1 in Image 2
    pts2Calculated = computeH(pts1, Hi);

    % Calculate the Euclidean distance between real and calculated points
    dist = sqrt(sum((pts2(1:2, :) - pts2Calculated(1:2, :)).^2));

    % Count the number of inliers
    inliers = find(dist < inlierThreshold);
    nInliers = length(inliers);

    if nInliers > nBest
        nBest = nInliers;
        H = Hi;
    end
end
end
