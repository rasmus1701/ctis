% generate synthetic ctis image
% d: datacube dimension
% lambda: number of spectral layers

function [f, g_out] = ctis_image_generator(d, lambda)
    bit = 256;            %maximum value of voxel in datacube.
    dist = 0;             %round(d/2); distance between 0th and 1st order
    Z = d*3 + lambda*2;     %FPA dimension
    midt = floor((Z)/2);
    background = zeros(Z, Z);
    image = background;

    % generate random object cube
    m = floor(bit * rand(d, d, lambda));
    mSum = zeros(d, d);
    for i = 1:lambda
        mSum = mSum + m(:,:,i);
    end

    % populate 0th order of ctis image
    for i = 1:d
        for j = 1:d
            image(midt-(d-1)/2+i, midt-(d-1)/2+j) = mSum(i, j);
        end
    end

    % populate 1st order of ctis image (8 diffractions)
    image = image * d / lambda;
    for h = 1:lambda
        for i = 1:d
            for j = 1:d
                image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j) = image(midt-(d-1)/2+i+d+dist+h, midt-(d-1)/2+j) + m(i,j,h);    %Bottom
                image(midt-(d-1)/2+i, midt-(d-1)/2+j+(d+dist+h)) = image(midt-(d-1)/2+i, midt-(d-1)/2+j+d+dist+h) + m(i,j,h);    %Right
                image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j) = image(midt-(d-1)/2+i-d-dist-h, midt-(d-1)/2+j) + m(i,j,h);    %Top
                image(midt-(d-1)/2+i, midt-(d-1)/2+j-(d+dist+h)) = image(midt-(d-1)/2+i, midt-(d-1)/2+j-d-dist-h) + m(i,j,h);    %Left
                image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h))+m(i,j,h);  %Bottom-Right
                image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h))+m(i,j,h);  %Bottom-Left
                image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h))+m(i,j,h);  %Top-Right
                image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h))+m(i,j,h);  %Top-Left
            end
        end
    end

    % reshape and return
    S = size(image, 1);
    f = m;
    g_out = reshape(image, S*S, 1);
endfunction
