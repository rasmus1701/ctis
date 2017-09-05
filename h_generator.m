% generate transfer matrix H
% d: system dimension
% lambda: number of spectral layers

function [H] = h_generator(d, lambda)
    h_iter = 1;
    H = zeros(9*d*d + 12*d*lambda + 4*lambda*lambda, d*d*lambda);

    % loop through data cube (x, y, lambda)
    for x_iter = 1:d
        for y_iter = 1:d
            for lambda_iter = 1:lambda
                dist = 0;
                Z = d*3 + lambda*2;
                midt = floor((Z)/2);

                % make empty diffraction image
                diff_image = zeros(Z, Z);

                % make datacube with 0s
                f = zeros(d, d, lambda);

                % sætter een voxel i kuben til 1 - denne skiftes for hver iteration.
                f(x_iter, y_iter, lambda_iter) = 1;

                % beregner 0te orden ved at summe alle spektral lag
                mSum = zeros(d, d);
                for i = 1:lambda
                    mSum = mSum + f(:, :, i);
                end

                % populate 0th order generated in the diff_image
                for i = 1:d
                    for j = 1:d
                        diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j) = mSum(i, j);
                    end
                end

                % scaling for plot
                diff_image = diff_image*d / lambda;

                % populate 1st order diffractions
                for h = 1:lambda
                    for i = 1:d
                        for j = 1:d
                            diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j) = diff_image(midt-(d-1)/2+i+d+dist+h, midt-(d-1)/2+j) + f(i, j, h);    %Bottom
                            diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j+(d+dist+h)) = diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j+d+dist+h) + f(i, j, h);    %Right
                            diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j) = diff_image(midt-(d-1)/2+i-d-dist-h, midt-(d-1)/2+j) + f(i, j, h);    %Top
                            diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j-(d+dist+h)) = diff_image(midt-(d-1)/2+i, midt-(d-1)/2+j-d-dist-h) + f(i, j, h);    %Left
                            diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) + f(i, j, h);  %Bottom-Right
                            diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = diff_image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) + f(i, j, h);  %Bottom-Left
                            diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) + f(i, j, h);  %Top-Right
                            diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = diff_image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) + f(i, j, h);  %Top-Left
                      	end
                    end
                end

                %diff_image
                % smider g-vektoren ind som en søjle i H kuben
                S = size(diff_image, 1);
                g = reshape(diff_image, S*S, 1);
                H(:, h_iter) = g;
                h_iter = h_iter + 1;
            end
        end
    end
endfunction
