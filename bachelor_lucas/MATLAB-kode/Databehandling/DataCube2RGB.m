function [ Image ] = DataCube2RGB( Cube )
% Omdanner en hyperspektral datakube til et RGB billede.
% Der antages, at for en kube med st�rrelsen (n x m x l), st�r st�r n for
% antallet af x-koordinater, m for antallet af y-koordinater og l for
% antallet af spektrale komponenter j�vn fordelt i omr�det 400 - 700 nm.
CubeSize = size(Cube); % Afl�s st�rrelsen p� kuben.
Nx = CubeSize(1); % Antal x-koordinater.
Ny = CubeSize(2); % Antal y-koordinater.
Ns = CubeSize(3); % Antal spektrale komponenter.
ds = (700 - 400)*10^-9 / (Ns-1); % Spektral opl�sning af datakuben.

% --- Opbyg billedematrice.
Image = zeros(Nx,Ny,3);
for i = 1:Nx
    for j = 1:Ny
        for k = 1:Ns
            % Bestem b�lgel�ngden.
            wavelength = 400*10^-9 + k*ds;
            % L�g intensiteten af den valgte b�lgel�ngde i RGB.
            rgb = wavelength2rgb(wavelength)*255*Cube(i,j,k);
            for l = 1:3
                Image(i,j,l) = Image(i,j,l) + rgb(l);
            end
        end
        % Divider med antal spektral komponenter, for at f� den
        % gennemsnitlig RGB kode.
        Image(i,j,:) = round(Image(i,j,:)/Ns);
    end
end
Image = uint8(255*Image/max(max(max(Image))));
end

