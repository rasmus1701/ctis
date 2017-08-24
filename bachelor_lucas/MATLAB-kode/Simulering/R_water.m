function [R] = R_water(lambda)
R = (3620043863771417*lambda)/4294967296 - (5851428571428553*lambda.^2)/8192 - 579/2800;
end