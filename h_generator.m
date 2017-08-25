% generate transfer matrix H
% d: system dimension
% lambda: number of spectral layers

function [H] = h_generator(d, lambda)
    h_iter = 1;
    H = zeros(9*d*d+12*d*lambda+4*lambda*lambda, d*d*lambda);

    # looper igennem alle punkter i datakuben (x, y, lambda)
    for x_iter = 1:d
        for y_iter = 1:d
            for lambda_iter = 1:lambda
                dist = 0;
                Z = d*3 + lambda*2;
                midt = floor((Z)/2);
                
                # laver et tomt billede
                background = zeros(Z, Z);
                image = background;

                % make datacube with 0s
                m = zeros(d, d, lambda);
                
                # sætter een voxel i kuben til 1 - denne skiftes for hver iteration.
                m(x_iter, y_iter, lambda_iter) = 1;
                mSum = zeros(d, d);

                # beregner 0te orden ved at summe alle spektral lag
                for i = 1:lambda
                    mSum = mSum+m(:, :, i);
                end

                # populate 0th order generated in the image
                for i = 1:d
                    for j = 1:d
                      image(midt-(d-1)/2+i, midt-(d-1)/2+j) = mSum(i, j);
                    end
                end

                image = image*d/lambda;

                % populate 1st order diffractions
                for h = 1:lambda
                    for i = 1:d
                      for j = 1:d
                        image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j) = image(midt-(d-1)/2+i+d+dist+h, midt-(d-1)/2+j)+m(i, j, h);    #Bottom
                        image(midt-(d-1)/2+i, midt-(d-1)/2+j+(d+dist+h)) = image(midt-(d-1)/2+i, midt-(d-1)/2+j+d+dist+h)+m(i, j, h);    #Right
                        image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j) = image(midt-(d-1)/2+i-d-dist-h, midt-(d-1)/2+j)+m(i, j, h);    #Top
                        image(midt-(d-1)/2+i, midt-(d-1)/2+j-(d+dist+h)) = image(midt-(d-1)/2+i, midt-(d-1)/2+j-d-dist-h)+m(i, j, h);    #Left
                        image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j+(d+dist+h))+m(i, j, h);  #Bottom-Right
                        image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = image(midt-(d-1)/2+i+(d+dist+h), midt-(d-1)/2+j-(d+dist+h))+m(i, j, h);  #Bottom-Left
                        image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h)) = image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j+(d+dist+h))+m(i, j, h);  #Top-Right
                        image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h)) = image(midt-(d-1)/2+i-(d+dist+h), midt-(d-1)/2+j-(d+dist+h))+m(i, j, h);  #Top-Left
                      end
                    end
                end

                #kalder datakuben for f for at synkronisere med litteratur
                f = m;
                S = size(image, 1);
                g = reshape(image, S*S, 1);

                # smider g-vektoren ind som en søjle i H kuben
                H(:, h_iter) = g;
                h_iter = h_iter + 1;
            end
        end
    end
endfunction
