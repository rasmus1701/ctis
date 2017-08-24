% Databehandling for CTIS system brugt i bachelor projekt. I denne m-fil
% prøves der at korrigere for vinkel offset af diffraktionsgitre og
% ekstrapolering af målepunkter.

close all
delete('log.txt')
diary off
diary('log.txt');diary on
global i_start i_left i_right i_top i_bottom i_0_width i_0_height % Alle punkterne laves globale.

% --- Parametre
N_wavelengths = 200; % Antal bølgelængder, der inkluderes.
lambda_u = 700*10^-9; % Øvre grænse for bølgelængde.
lambda_l = 400*10^-9; % Nedre grænse for bølgelængde.
lambda_u_crop = 680*10^-9; % Øverste bølgelængde, der vises.
lambda_l_crop = 420*10^-9; % Nederste bølgelængde, der vises.
Edge_crop = 0; %0.05; % Brøkdel af kanterne der klippes væk (rummeligt).

% Størrelse af 0. orden.
i_0_width = 985:1058;
i_0_height = 1007:1080;

% Diffraktionsbilleder der indlæses.
Image0 = imread('æbler 0.ppm'); % 0. ordens billede.
Image = imread('æbler diff.ppm'); % 1. ordens billede.

% --- Målepunkter fra kalibrering.
% Har følgende format:
% [wave1_left, wave1_right, wave1_top, wave1_bottom ; ...
%  wave2_left, wave2_right, wave2_top, wave2_bottom ; ...
%  wave3_left, wave3_right, wave3_top, wave3_bottom ];
% Hvert celle måler hvor lang punktet ligger ud i diffraktionen. Dvs fx i
% den lodrette diffraktion, der kigges der kun på y-koordinaten.

i_NW = [550, 1432, 569, 1464; ... % 400nm
        471, 1510, 494, 1541; ... % 475nm
        382, 1596, 409, 1628; ... % 550nm
        291, 1684, 322, 1721; ... % 625nm
        194, 1774, 230, 1810];    % 700nm
     
i_NE = [598, 1482, 570, 1459; ... % 400nm
        520, 1561, 495, 1542; ... % 475nm
        433, 1644, 410, 1634; ... % 550nm
        342, 1733, 321, 1723; ... % 625nm
        251, 1826, 232, 1811];    % 700nm
     
i_SW = [547, 1436, 617, 1505; ... % 400nm
        464, 1513, 540, 1593; ... % 475nm
        376, 1597, 457, 1684; ... % 550nm
        284, 1684, 369, 1774; ... % 625nm
        190, 1774, 281, 1869];    % 700nm
     
i_SE = [596, 1484, 625, 1506; ... % 400nm
        512, 1561, 541, 1595; ... % 475nm
        427, 1645, 456, 1683; ... % 550nm
        336, 1735, 369, 1774; ... % 625nm
        244, 1829, 281, 1866];    % 700nm
    
% Målepunkter af kalibreringspunkter i 0. orden (x,y).
i_0_NW = [992 1019];
i_0_NE = [1038 1019];
i_0_SW = [991 1065];
i_0_SE = [1037 1066];
     

% |||                                                                  |||
% ||| ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ |||
% |||    !!!   Alt kode ligger under her.   !!!                        |||
% ||| ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ |||
% VVV                                                                  VVV

% -------------------------------------------------------------------------
% Bestem en kvardratisk 0. orden ud fra input.
% -------------------------------------------------------------------------
dlength = abs(length(i_0_width) - length(i_0_height));
if length(i_0_width) > length(i_0_height)
    i_0_width = i_0_width(1 + ceil(dlength/2) : length(i_0_width) - floor(dlength/2) );
elseif length(i_0_width) < length(i_0_height)
    i_0_height = i_0_height(1 + ceil(dlength/2) : length(i_0_height) - floor(dlength/2) );
end
N_0 = length(i_0_width); % Størrelse (sidelængde) af 0. orden.
% Center koordinat for 0. orden.
i_0_center(1) = median(i_0_height); % Række.
i_0_center(2) = median(i_0_width); % Kolonne.

% -------------------------------------------------------------------------
% Ekstrapoler kalibreringspunkter i diffraktionerne, så de svarer til at
% være taget fra hjørnerne af 0. orden.
% -------------------------------------------------------------------------
% NW-koordinater.
i_0_displacement = i_0_NW - [min(i_0_width) , min(i_0_height)];
i_NW(:,1) = i_NW(:,1) - i_0_displacement(1); % Venstre.
i_NW(:,2) = i_NW(:,2) - i_0_displacement(1); % Højre.
i_NW(:,3) = i_NW(:,3) - i_0_displacement(2); % Top.
i_NW(:,4) = i_NW(:,4) - i_0_displacement(2); % Bund.

% NE-koordinater.
i_0_displacement = i_0_NE - [max(i_0_width) , min(i_0_height)];
i_NE(:,1) = i_NE(:,1) - i_0_displacement(1); % Venstre.
i_NE(:,2) = i_NE(:,2) - i_0_displacement(1); % Højre.
i_NE(:,3) = i_NE(:,3) - i_0_displacement(2); % Top.
i_NE(:,4) = i_NE(:,4) - i_0_displacement(2); % Bund.

% SW-koordinater.
i_0_displacement = i_0_SW - [min(i_0_width) , max(i_0_height)];
i_SW(:,1) = i_SW(:,1) - i_0_displacement(1); % Venstre.
i_SW(:,2) = i_SW(:,2) - i_0_displacement(1); % Højre.
i_SW(:,3) = i_SW(:,3) - i_0_displacement(2); % Top.
i_SW(:,4) = i_SW(:,4) - i_0_displacement(2); % Bund.

% SE-koordinater.
i_0_displacement = i_0_SE - [max(i_0_width) , max(i_0_height)];
i_SE(:,1) = i_SE(:,1) - i_0_displacement(1); % Venstre.
i_SE(:,2) = i_SE(:,2) - i_0_displacement(1); % Højre.
i_SE(:,3) = i_SE(:,3) - i_0_displacement(2); % Top.
i_SE(:,4) = i_SE(:,4) - i_0_displacement(2); % Bund.

% -------------------------------------------------------------------------
% Bestem hvor langt hvert målte bølgelængde bevæger sig ud i diffraktion ud
% fra punktet ved 400nm tættest på 0. orden. 
% -------------------------------------------------------------------------
% Startpunkt for hver diffraktion. Dvs den korteste punkt til 0. orden.
i_start(1) = floor((i_NE(1,1) + i_SE(1,1))/2); % Start koordinat for venstre.
i_start(2) = ceil((i_NW(1,2) + i_SW(1,2))/2); % Start koordinat for højre.
i_start(3) = floor((i_SW(1,3) + i_SE(1,3))/2); % Start koordinat for øvre.
i_start(4) = ceil((i_NW(1,4) + i_NE(1,4))/2); % Start koordinat for nedre.


% Opbyg for venstre diffraktion.
i_left = zeros(size(i_NW,1),2);
for i = 1:size(i_left,1)
    i_left(i,2) = i_start(1) - ceil((i_NW(i,1) + i_SW(i,1))/2) + 1;
    i_left(i,1) = i_start(1) - floor((i_NE(i,1) + i_SE(i,1))/2) + 1;
end

% Opbyg for højre diffraktion.
i_right = zeros(size(i_NW,1),2);
for i = 1:size(i_right,1)
    i_right(i,1) = ceil((i_NW(i,2) + i_SW(i,2))/2) - i_start(2) + 1;
    i_right(i,2) = floor((i_NE(i,2) + i_SE(i,2))/2) - i_start(2) + 1;
end

% Opbyg for øvre diffraktion.
i_top = zeros(size(i_NW,1),2);
for i = 1:size(i_right,1)
    i_top(i,2) = i_start(3) - ceil((i_NW(i,3) + i_NE(i,3))/2) + 1;
    i_top(i,1) = i_start(3) - floor((i_SW(i,3) + i_SE(i,3))/2) + 1;
end

% Opbyg for nedre diffraktion.
i_bottom = zeros(size(i_NW,1),2);
for i = 1:size(i_right,1)
    i_bottom(i,1) = ceil((i_NW(i,4) + i_NE(i,4))/2) - i_start(4) + 1;
    i_bottom(i,2) = floor((i_SW(i,4) + i_SE(i,4))/2) - i_start(4) + 1;
end


% -------------------------------------------------------------------------
% Tilpas og klip diffraktionsbillederne.
% -------------------------------------------------------------------------
Image(824:1224,824:1224) = Image0(824:1224,824:1224); % Læg 1. orden sammen med 0. orden.
Image = im2double(Image); % Konverter til double.
NoiseLevel = quantile(Image(:),0.85); % Støjgulv. Da langt det meste af billedet ikke er belyst, er 0.85 kvartil en meget god estimat.
Image = Image - NoiseLevel; % Fjern støjgulv.
Image(Image<0.0001) = 0.0001; % Minimumsværdi.

% % --- Plot til sammenligning.
% figure
% subplot(1,2,1)
% imshow(Image)
% title('Diffraction image.')
% subplot(1,2,2)
% imhist(Image)
% title('Histogram.')

% -------------------------------------------------------------------------
% Serialiser diffraktionsbillede.
% -------------------------------------------------------------------------
[g] = SerializeImage_RealV2(Image,i_0_width,i_0_height);

% -------------------------------------------------------------------------
% Opbyg H-matrice for systemet og genskab billede.
% -------------------------------------------------------------------------
% --- Opbyg H-matricen for det optiske system.
[H] = BuildMatrixH_Real_V3(N_wavelengths,N_0);

% --- Estimere det originale billede som serialiseret vektor f.
f = ExpectationMaximation(g,H,N_0,N_0,N_wavelengths,lambda_l,lambda_u,lambda_l_crop,lambda_u_crop);
EstCube = RebuildDataCube( f,N_0,N_0,N_wavelengths );

% Skær dele af kuben væk, både rummeligt og spektralt.
[EstCube,lambda_min,lambda_max] = CropCube(EstCube,lambda_l,lambda_u,lambda_u_crop,lambda_l_crop,Edge_crop);
% lambda_min = lambda_l;lambda_max = lambda_u;

% % Udglat kuben spektralt.
EstCube = SmoothCubeSpectral( EstCube,20 );

% Udglat datakuben (både spssektralt og rummeligt)
% EstCube = smooth3(EstCube,'gaussian',[9,9,1]);

% Normaliser og korriger for kameraets respons.
EstCube = CorrectError( EstCube,lambda_min,lambda_max);

plotCube = DataCube2RGB(EstCube);

% Plot billede
figure
subplot(1,2,1)
imshow(Image)
title(sprintf('Diffracted picture, %g x %g pixels.',size(Image,2),size(Image,1)))

subplot(1,2,2)
imshow(plotCube);
title(sprintf('Estimated picture, %g x %g pixels.',N_0,N_0))

% Visualiser kube
figure
VisualizeCube(EstCube,lambda_min,lambda_max)

% Exporter billede
Export2Gerbil( EstCube,lambda_min,lambda_max )

diary off

