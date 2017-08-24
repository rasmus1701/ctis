function [ Cube ] = BuildDataCube(Nx,Ny,Ns,lambda_l,lambda_u,varargin)
% Function returnerer en kunstig veldefineret datakube, ud fra input. Den
% har følgende form:
% Cube = BuildDataCube(Nx,Ny,Ns,lambda_l,lambda_u,[type],[property],[value],[property],[value],...)
% [...] angiver optional argumenter.
% -----------------------------------
% Input parametre:
% Nx - Rumlig størrelse i x-aksen.
% Ny - Rumlig størrelse i y-aksen.
% Ns - Antal spektrale bånd i kuben.
% lambda_l - Den korteste bølgelængde i kuben [SI-enhed].
% lambda_u - Den længste bølgelængde i kuben [SI-enhed].
% [type] - Hvilken fikur/mønster ønskes i kuben (uddybes længere nede).
% [property],[value] - Egenskab og korresponderende værdi, der ønskes
% ændret.
% -----------------------------------
% Type af kuber:
% 'default' - Rund kødklump i midten, omgivet af en firkantet plante og
% støjet baggrund. Derudover er der små blå LED-punkter spredt tilfældig.
% Den er valgt som standard.
% 'full' - Rummeligt fuldt belyst kube. Farven kan angives.
% 'dot' - Rummelig prik. Størrelse, placering og farve kan angives.
% -----------------------------------
% Parametre:
% 'wavelength' - Angiv farven for 'full' eller 'dot'. Dette gøres ved at
% udvælge en bølgelængde i SI-enhed. Alternativt vælges 'all', for et hvidt
% spektrum. (default = 'all')
% 'sigma' - Angiv standradafvigelsen af farvens gaussiske fordeling for
% typen 'full' eller 'dot'. For sigma = 0 antages en komplet monokrom 
% fordeling. (default = 0)
% 'radius' - Radius af prikken i typen 'dot'. Målt i antal rumlige pixel. 
% (default = 0)
% 'position' - Position for prikken i typen 'dot'. (default = [Nx/2 , Ny/2])
% 'spectralmodperiod' - Spectral periodeafstand for en sinusmodelering i
% kubens spektrale akse. Ved spectralmodperiod = 0 laves ingen modulering.
% (default = 0).
% -----------------------------------
% Eksempler:
% 10 pixel x 10 pixel x 5 bånd datakube, med default indstillinger.
% Cube = BuildDataCube(10,10,5,400*10^-9,700*10^-9)
%
% 10 pixel x 10 pixel x 5 bånd datakube, med en prik med en gaussisk
% fordelt farve på 520nm med sigma = 10 nm, placeret i hjørnet:
% Cube = BuildDataCube(10,10,5,400*10^-9,700*10^-9,'dot','wavelength',520*10^-9,'sigma',10*10^-9,'position',[2,2])
%

% Default værdier.
sigma = 0;
boolWhite = 0;
color = 550*10^-9; % Default monokrom farve.
radius = 1;
position = round([Nx/2 , Ny/2]);
strCube = '';
spectralmodperiod = 0;

InputManager % Styring af input fra 'varagin'.

% --- Opret datakube med billede i blænden.
dlambda = (lambda_u - lambda_l)/(Ns-1); % Spektral afstand mellem bølgelængder.

switch strCube
    case 'default'
        Cube = DefaultCube;
    case 'full'
        Cube = FullCube;
    case 'dot'
        Cube = DotCube;
    otherwise
        Cube = DefaultCube;   
end

% --- Moduler spektral akse af datakuben.
if spectralmodperiod ~= 0
    for k = 1:Ns
        wave = lambda_l + (k-1)*dlambda;
        Cube(:,:,k) = Cube(:,:,k) * (0.5 + 0.5*sin(2*pi*wave/spectralmodperiod));
    end
end



% Normaliser kuben:
Cube = Cube/max(Cube(:));

% | ===================================================================== |
% | ===================================================================== |
% | Nested funktioner                                                     |
% | ===================================================================== |
% V ===================================================================== V
% -------------------------------------------------------------------------
% Inputstyring.
% -------------------------------------------------------------------------
function InputManager
    
    % Hvilken type kube?
    if length(varargin) > 0
        if ischar(varargin{1})
            strCube = varargin{1};
        end
    end
    
    % Hvilke ekstra properties justeres?
    if length(varargin) > 1
        if mod(length(varargin),1) == 1
            error('Wrong number of arguments')
        end
        for i = 2:2:length(varargin)
            switch varargin{i}
                case 'wavelength'
                    % Hvid eller monokromt?
                    if ischar(varargin{i+1})
                        if strcmp(varargin{i+1},'all')
                            boolWhite = 1;
                        end
                    end

                    % Hvilken farve, hvis monokrom?
                    if ~boolWhite
                        if length(varargin) > 1
                            if isnumeric(varargin{i+1})
                                color = varargin{i+1};
                            end
                        end    
                    end
                case 'sigma'
                    sigma = varargin{i+1};
                case 'radius'
                    radius = varargin{i+1};
                case 'position'
                    position = varargin{i+1};
                case 'spectralmodperiod'
                    spectralmodperiod = varargin{i+1};
                otherwise
                    error('Unknown argument %s.\n',varargin{i});
            end
        end
    end
end


% | ===================================================================== |
% | ===================================================================== |
% | Definition af de forskellige typer datakuber.                         |
% | ===================================================================== |
% V ===================================================================== V

% -------------------------------------------------------------------------
% default, Den oprinde kube der blev afprøvet.
% -------------------------------------------------------------------------
function Cube = DefaultCube
    % Opret sort baggrund med støj.
    Cube = 0.01*rand(Nx,Ny,Ns);
    
    %Der oprettes en firkantet plante i midten.
    for i = round(Nx/4):round(Nx*3/4)
        for j = round(Ny/5):round(Ny*4/5)
            for k = 1:Ns
                lambda = (k-1)*dlambda + lambda_l; % Den valgte bølgelængde.
                Cube(i,j,k) = R_plant(lambda)*(1+0.5*rand); % Reflektans lægges ind.
            end
        end
    end

    % Der oprettes en rund kødstump.
    for i = round(Nx/4):round(Nx*3/4)
        temp = circ_vectors(i,Nx/4,Nx*3/4,Ny/4,Ny*3/4);
        for j = temp
            for k = 1:Ns
                lambda = (k-1)*dlambda + lambda_l; % Den valgte bølgelængde.
                Cube(i,j,k) = R_meat(lambda)*(1+0.5*rand);
            end
        end
    end

    % Placer tilfældige blå-prikker.
    N_dirt = randi([10 20],1,1);
    r = round(Nx/100); % Radius af prikker.
    for l = 1:N_dirt;
        % Tilfældig position;
        n = randi([1+r, Nx-r],1,1);
        m = randi([1+r, Ny-r],1,1);
        % Placer prik.
        for i = n-r:n+r
            temp = circ_vectors(i,n-r,n+r,m-r,m+r);
            if ~isnan(temp)
                for j = temp
                    for k = 1:Ns
                        lambda = (k-1)*dlambda + lambda_l; % Den valgte bølgelængde.
                        Cube(i,j,k) = R_blue(lambda)*(1+0.5*rand);
                    end
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
% full, en fuld belyst datakube, enten hvid eller monokromt.
% -------------------------------------------------------------------------
function Cube = FullCube    
    % --- Opbyg datakube.    
    if boolWhite 
        % Opbyg hvid kube.
        Cube = ones(Ny,Nx,Ns); % Initialiser datakuben med 1'ere.
    else
        % Opbyg monokrom kube.
        Cube = zeros(Ny,Nx,Ns); % Initialiser datakuben med 0'ere.
        if sigma <= 0
            % Bestem bølgeindeks k for den monokrome bølge. Hvis den valgte
            % bælge ligger mellem to indeks af k, laves interpolation.
            k_wave = (color - lambda_l)/dlambda + 1;
            k_indeces(2) = ceil(k_wave); k_indeces(1) = floor(k_wave);
            if min(k_indeces) == max(k_indeces)
                k_indeces = k_indeces(1);
            end

            for k = k_indeces
                Cube(:,:,k) = 1 - abs(k_wave - k);
            end
        else
            % Lave gaussisk fordeling af farven.
            mean = color;
            waves = lambda_l + (0:(Ns-1))*dlambda;
            amplitude = normpdf(waves,mean,sigma);
            for k = 1:Ns
                Cube(:,:,k) = amplitude(k);
            end
        end
    end
end

% -------------------------------------------------------------------------
% dot, En punktkilde, som er en cirkel, hvor størrelsen og position kan 
% angives.
% -------------------------------------------------------------------------
function Cube = DotCube
    Cube = zeros(Ny,Nx,Ns); % Initialiser datakuben med 0'ere.
    
    % --- Opbyg hyperspektral dot.
    mat = dot_mask(radius); % Rummelig matrice for dot.
    circle = zeros(size(mat,1),size(mat,2),Ns); % Hyperspektral kube med cirklen.
    % Ydfyld datakuben for dot.
    if boolWhite 
        % Opbyg hvid kube.
        for k = 1:Ns
            circle(:,:,k) = mat;
        end
    else
        % Opbyg monokrom kube.
        if sigma <= 0
            % Bestem bølgeindeks k for den monokrome bølge. Hvis den valgte
            % bælge ligger mellem to indeks af k, laves interpolation.
            k_wave = (color - lambda_l)/dlambda + 1;
            k_indeces(2) = ceil(k_wave); k_indeces(1) = floor(k_wave);
            if min(k_indeces) == max(k_indeces)
                k_indeces = k_indeces(1);
            end

            for k = k_indeces
                circle(:,:,k) = (1 - abs(k_wave - k)) * mat;
            end
        else
            % Lave gaussisk fordeling af farven.
            mean = color;
            waves = lambda_l + (0:(Ns-1))*dlambda;
            amplitude = normpdf(waves,mean,sigma);
            for k = 1:Ns
                circle(:,:,k) = amplitude(k) * mat;
            end
        end
    end
    
    % --- Placer den hyperspektrale cirkel i den hyperspektrale datakube.
    indeces_x = ((-radius):radius) + position(1);
    indeces_y = ((-radius):radius) + position(2);
    Cube(indeces_y,indeces_x,:) = circle(:,:,:);
end
end
