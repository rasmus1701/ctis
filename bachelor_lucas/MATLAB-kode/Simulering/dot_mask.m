function [ mat ] = dot_mask(radius )
% Returnerer en matrice med værdier fra 0 til 1, sat op i en fyldt cirkel.
mat = zeros(1 + ceil(radius)*2); % Initialiser matricen.
r_0 = ceil(size(mat)/2); % Center koordinat.

for x = 1:size(mat,1);
    for y = 1:size(mat,2);
        r = [x,y];
        if norm(r - r_0) - radius <= 0
            mat(x,y) = 1;
        elseif norm(r - r_0) - radius < 1
            mat(x,y) = 1 - (norm(r - r_0) - radius);
        end
    end
end



end

