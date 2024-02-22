function [imgcomposed, displacement] = composeimgsV2(img1, img2, H)
    
	%adaptaded composeimgs() version, i had some issues when using composeimgs() when inputing img2(middle img) and
	% img3(right img).	

    debug = 0;

    % Calculate the corners of img1 and apply the transformation
    [sizey, sizex, chans] = size(img1);
    corners = [1, 1, 1; 1, sizey, 1; sizex, sizey, 1; sizex, 1, 1];
    cornersh = (H * corners')';
    cornersh = cornersh ./ cornersh(:, 3); % Normalize by the third coordinate

    % Calculate translation values
    minvals = min(cornersh);
    maxvals = max(cornersh);
    %if (minvals(1) < 1)
    tx = abs(floor(1 - minvals(1)));
    %else
    %   tx = 0;
    %end
       
    if (minvals(2) < 1)
        ty = floor(1 - minvals(2));
    else
        ty = 0;
    end
    
    if (maxvals(2) > sizey)
        deltay = ceil(maxvals(2) - sizey);
    else
        deltay = 0;
    end
       
    if (maxvals(1) > sizex)
        deltax = ceil(maxvals(1) - sizex);
    else
        deltax = 0;
    end
    
    newsize = [sizey + 2*ty + deltay + 1, sizex + tx + deltax, chans];
    newimg = uint8(zeros(newsize));
    newimg2 = newimg;

    % Warp img2 with the transformation matrix H
    img2t = imwarp(img2, projective2d(H'));
    
    newimg(1 + ty:ty + sizey, 1 + 0:0 + sizex, :) = img1;
    newimg2(1 + 0: 0+size(img2t, 1), 1+tx: tx+size(img2t, 2), :) = img2t;
    imgcomposed = max(newimg, newimg2);
    displacement = [ty, tx];

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