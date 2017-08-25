dim = 3;
lambda = 5;
iterations = 10;
if nargin == 3
    dim = str2num(argv(){1});
    lambda = str2num(argv(){2});
    iterations = str2num(argv(){3});
else
    printf("Usage: %s dim lambda iterations\n", program_name());
    printf("Using default dim, lambda, and iterations\n");
end
printf("Computing CTIS image for system of dimension %d and %d spectral layers, using %d iterations\n", dim, lambda, iterations);

%run("h_generator")
%run("ctis_image_generator");
H = h_generator(dim, lambda);
[f, g] = ctis_image_generator(dim, lambda);
f_calc = exp_max(H, g, iterations, dim, lambda);
err = abs(f-f_calc)