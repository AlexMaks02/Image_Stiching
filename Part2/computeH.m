function y = computeH(x, v)
% HOMOGRAPHY TRANSFORM, applies homographic transform to vectors
%Function used to compute the correspondent points in other image,
%given an homography matrix
q = v * x;
p = q(3,:);
y = [q(1,:)./p; q(2,:)./p];
end

