function [ SmoothedCube ] = SmoothCubeSpectral( Cube,sigma )
% Udglatter kuben spektralt (IKKE RUMMELGIT).

SmoothedCube = zeros(size(Cube)); % Initialiser output kuben.

g = gausswin(sigma); % Bredden af gaussvindue. 1/15 af antallet af bånd.
g = g/sum(g); % Normaliser vindue.

for i = 1:size(Cube,1)
    for j = 1:size(Cube,2)
        PointSpectrum = Cube(i,j,:); % Spektrum for et enkelt pixel.
        PointSpectrum = PointSpectrum(:); % Konverter til en vektor.
        SmoothedCube(i,j,:) = conv(PointSpectrum, g, 'same');
    end
end

end

