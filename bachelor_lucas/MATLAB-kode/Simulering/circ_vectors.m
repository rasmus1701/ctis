function [ j ] = circ_vectors(i,i_min,i_max,j_min,j_max)
% Returnerer vector for at tegne en cirkel/vector i et område i en 2D-billede.
delta_i = i_max - i_min;
delta_j = j_max - j_min;

j_center = (j_min + j_max)/2;

% Opbyg j-vector.
j1 = round(j_center - delta_j/2*sin(2*pi/delta_i/2*(i-i_min)));
j2 = round(j_center + delta_j/2*sin(2*pi/delta_i/2*(i-i_min)));
j = j1:j2;

