function [ Cube ] = RebuildDataCube( f,Nx,Ny,Ns )
% Ud fra en serialiseret kube i form af en vector, genopbygges kuben igen.
% Der antages at den er serialiseret på følgende måde:
% f((l-1)*Nx*Ny + (y-1)*Ny + x) = Cube(x,y,l)

% --- Test om de angivne dimensioner (Nx,Ny,Ns) passer overens med den
% serialiserede vektor.
if length(f) ~= Nx*Ny*Ns
    error('Number of cells in vector f not equal to the number og cells of the datacube: length(f) ~= Nx*Ny*Ns.')
end

% --- Opbyg datakuben.
Cube = zeros(Nx,Ny,Ns); % initialiser kuben.
for k = 1:Ns
    for j = 1:Ny
        for i = 1:Nx
            index = (k - 1)*Nx*Ny + (i-1)*Nx + j;
            Cube(i,j,k) = f(index);
        end
    end
end

% --- Normaliser
Cube = Cube/max(Cube(:));

end



