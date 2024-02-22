function [imgcomposed,displacement]=composeimgs(img1, img2,H)
% Author: Paulo Menezes - 2020
% compose 2 images given the transformation warping matrix of the second
% img1 the one that will be kept untransformed
% img2 the one to be warped 
% H the warping transformation
% returns a new image and the transformation of the original image on this
% image

%
% It should be noted that the image to be warped may appear to the left,
% right and/or upper or lower side of the fixed one. This means that 
% for the left and upper sides, the fixed image will be transformed as
% well, even if it is just by a translation.
debug = 0;
[sizey,sizex,chans]=size(img1);

corners=[1,1,1];
A=H * corners';
cornersh(1,:)=A/A(3);

corners=[1,sizey, 1];
A=H * corners';
cornersh(2,:)=A/A(3);

corners=[sizex,sizey, 1];
A=H * corners';
cornersh(3,:)=A/A(3);

corners=[sizex, 1,1];
A=H * corners';
cornersh(4,:)=A/A(3);

minvals=min(cornersh);
maxvals=max(cornersh);
if (minvals(1)<1)
    tx=floor(1-minvals(1));
else
    tx=0;
end
if(minvals(2)<1)
    ty=floor(1-minvals(2));
else
    ty=0;
end

if(maxvals(2)>sizey)
    deltay=ceil(maxvals(2)-sizey);
else
    deltay=0;
end

if(maxvals(1)>sizex)
    deltax=ceil(maxvals(1)-sizex);
else
    deltax=0;
end
newsize=[sizey+ty+deltay+1, sizex+tx+deltax, chans];

newimg=uint8(zeros(newsize));
newimg2=newimg;
newimgs=size(newimg);

%[img2t,displacement2]=warpimage(img2,H);
img2t=imwarp(img2,projective2d(H'));
img2tsize=size(img2t);

newimg(1+ty:ty+sizey,1+tx:tx+sizex,:)=img1;
newimg2(1:img2tsize(1),1:img2tsize(2),:)=img2t;

[newimg_sizex,newimg_sizey,~] = size(newimg);
[newimg2_sizex,newimg2_sizey,~] = size(newimg2);

if (newimg_sizex ~= newimg2_sizex) || (newimg_sizey ~= newimg2_sizey) 
    disp(['newimg_sizex:',num2str(newimg_sizex),' newimg_sizey:',num2str(newimg_sizey)]);
    disp(['newimg2_sizex:',num2str(newimg2_sizex),' newimg2_sizey:',num2str(newimg2_sizey)]);
end


imgcomposed = max(newimg,newimg2);

displacement=[ty,tx];
 
    if debug ==1
        % Debug: Display corners and transformed corners
        disp('Corners (Original and Transformed):');
        disp([corners; cornersh]);
        disp(['tx:',num2str(tx)]);
        disp(['ty:',num2str(ty)]);

        % Display the transformation matrix H
        disp('Homography Matrix H:');
        disp(H);

        % Debug: Display tx and ty
        disp(['Translation [tx, ty]: [' num2str(tx) ', ' num2str(ty) ']']);

        disp(['deltax:',num2str(deltax)]);
        disp(['deltay:',num2str(deltay)]);
        % Debug: Display the size of img2t
        disp('Size of img2t:');
        disp(size(img2t));

        [newimg_sizex,newimg_sizey,~] = size(newimg);
        [newimg2_sizex,newimg2_sizey,~] = size(newimg2);
        disp(['newimg_sizex:',num2str(newimg_sizex),' newimg_sizey:',num2str(newimg_sizey)]);
        disp(['newimg2_sizex:',num2str(newimg2_sizex),' newimg2_sizey:',num2str(newimg2_sizey)]);

        % Debug: Display displacement values
        disp('Displacement [ty, tx]:');
        disp(displacement);

        % Debug: Display newimg
        figure;
        imshow(newimg);
        title('New Image (img1)');

        % Debug: Display newimg2
        figure;
        imshow(newimg2);
        title('New Image (img2t)');

        % Debug: Display the composed image
        figure;
        imshow(imgcomposed);
        title('Composed Image');
    end

end
