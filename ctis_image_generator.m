% generate synthetic ctis image
% d: datacube dimension
% lambda: number of spectral layers

function [f, g_out] = ctis_image_generator(d, lambda)
    bit = 256;            %maximum value of voxel in datacube.
    dist = 0;             %round(d/2); distance between 0th and 1st order
    Z = d*3 + lambda*2;     %FPA dimension
    midt = floor((Z)/2);
    background = zeros(Z, Z);
    diff_image = background;

    % generate random object cube
    m = floor(bit * rand(d, d, lambda));
    mSum = zeros(d, d);
    for i = 1:lambda
        mSum = mSum + m(:,:,i);
    end

    % populate 0th order of ctis diff_image
    for i = 1:d
        for j = 1:d
            diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j) = mSum(i, j);
        end
    end

    % populate 1st order of ctis diff_image (8 diffractions)
    diff_image = diff_image * d / lambda;
    for h = 1:lambda
        for i = 1:d
            for j = 1:d
                diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j) = diff_image(midt-(d-1)/2+i+d+dist+h, midt-(d-1)/2+j) + m(i,j,h);    %Bottom
                diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j+(d+dist+h)) = diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j+d+dist+h) + m(i,j,h);    %Right
                diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j) = diff_image(midt-(d-1)/2+i-d-dist-h, midt-(d-1)/2+j) + m(i,j,h);    %Top
                diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j-(d+dist+h)) = diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j-d-dist-h) + m(i,j,h);    %Left
                diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h))+m(i,j,h);  %Bottom-Right
                diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h))+m(i,j,h);  %Bottom-Left
                diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h))+m(i,j,h);  %Top-Right
                diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h))+m(i,j,h);  %Top-Left
            end
        end
    end

    % reshape and return
    S = size(diff_image, 1);
    f = m;
    g_out = reshape(diff_image, S*S, 1);
endfunction
