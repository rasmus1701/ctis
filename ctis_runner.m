lambda = 5;
if nargin>0
  lambda = str2num(argv(){1});
end

run("h_generator")
run("ctis_image_generator");
f_calc = exp_max(H,g,100,3,lambda);
err = abs(f-f_calc)

