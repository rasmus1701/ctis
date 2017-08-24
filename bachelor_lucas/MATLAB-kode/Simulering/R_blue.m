function [R] = R_plant(lambda)
% Spektral fordeling for planter.
sigma = 25*10^-9;
mu = 450*10^-9;
R = 4*exp(-(lambda-mu).^2/(2*sigma^2));
end