function HomographyMat = ComputeHomography(pts1, pts2)

HomographyMat = [];

for i = 1:length(pts1)
    HomographyMat = [HomographyMat;
                    -pts1(i,1) -pts1(i,2) -1 0 0 0 pts1(i,1)*pts2(i,1) pts1(i,2)*pts2(i,1) pts2(i,1);
                    0 0 0 -pts1(i,1) -pts1(i,2) -1 pts1(i,1)*pts2(i,2) pts1(i,2)*pts2(i,2) pts2(i,2)];
end

%Singular value decomposition
[U, S, V] = svd(HomographyMat);

HomographyMat = [V(1:3,end)'; V(4:6,end)'; V(7:9,end)'];

end