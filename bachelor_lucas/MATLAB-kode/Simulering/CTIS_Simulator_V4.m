delete('log.txt')
diary off
diary('log.txt');diary on
close all

% Simulation of a CTIS system used in a bachelor project.
% Der tages udgangspunkt fra billedet dannet i blænden i systemet. De
% nødvendige parametre for systemet er derved:
f(1) = 0; % Fokallængde for imaging linse.
f(2) = 150*10^-3; % Fokallængde for collimating lens.
f31 = -30*10^-3; % Fokallængde for reimaging lens 1.
f32 = 50*10^-3; % Fokallængde for reimaging lens 2.
f33 = 30*10^-3; % Fokallængde for reimaging lens 3.
L31 = 30*10^-3; % Afstand mellem reimaging linse 1 -> 2.
L32 = 10*10^-3; % Afstand mellem reimaging linse 2 -> 3.
f(3) = (f31*f32*f33) / (f31*f32 + f32*f33 + f33*f31 - f31*L32 -f32*L31 - f32*L32 - f33*L31 + L31*L32);
a = (10^-3)/500; % Periodeafstand i gitter.
h_A = 3.5*10^-3; % Den halve sidelængde af blænde.
h_cam = 5.5*10^-3; % Den halve sidelængde af sensorfladens sidelængde.

% --- Yderligere parametre for simulering.
N_object = 90; % Antal pixler i sidelængde for object i blænden.
N_cam = 1500; % Antal pixler i sidelængde for image på sensorfladen.
N_wavelengths = 100; % Antal bølgelængder, der inkluderes.
N_wave_estimate = 50; % Antal bølgelængde der estimeres på.
NumOfCaliPoints = N_wave_estimate; % Antal kalibreringspunkter.
lambda_u = 700*10^-9; % Øvre grænse for bølgelængde.
lambda_l = 400*10^-9; % Nedre grænse for bølgelængde.
lambda_u_crop = 700*10^-9; % Øverste bølgelængde, der vises.
lambda_l_crop = 400*10^-9; % Nederste bølgelængde, der vises.
Edge_crop = 0.00; % Brøkdel af kanterne der klippes væk (rummeligt).
boolCamRespons = false; % Skal kameraets respons medregnes?
boolLightSource = false; % Skal lyskildens spektrum medregnes?

% --- Støj parametre.
noisefloor = 0.0001; % 0.0001; % Niveau for støjgulv.
SigmaGaussBlurr = 0; %1; % Sigmaværdi for gaussisk filter til udtværring af billede.
SigmaGaussNoise = 0.0000; % 0.0001; % Sigmaværdi for gaussisk støj.
SigmaCali = 0; % 2; % Sigmaværdi for kalibreringspunkter.
N_disp = 0; % 50; % Antal pixler den ene diffraktion skal forskydes i forhold til den anden (målt i afstand til 0. orden.).
angle = 0.0; % 0.5; % Antal grader billedet roteres.


% -------------------------------------------------------------------------
% Initialisering af original billede.
% -------------------------------------------------------------------------
% --- Opret datakube.
% Opret et foruddefineret hyperspektralt billede.
Cube = BuildDataCube(N_object,N_object,N_wavelengths,lambda_l,lambda_u,'dot','wavelength','all','radius',25);
% Cube = load('SaveData\Cube_4MP_200spec_perfect.mat');Cube = Cube.Cube; MsgBox('Cube loaded');

% -------------------------------------------------------------------------
% Simulering af optisk system.
% -------------------------------------------------------------------------
% Fra hvert punkt projiceres det ud fra blænde til kamera. Alle ordner
% inden for kameraets omfang medtages.
Image0 = SimulateSystemV3( Cube, N_cam, lambda_l,lambda_u,f,a,h_A,h_cam,boolCamRespons,boolLightSource);
% Image0 = load('SaveData\Image_4MP_200spec_perfect.mat');Image0 = Image0.Image; MsgBox('Image loaded');

% -------------------------------------------------------------------------
% Tilsæt støj og andre forstyrrelser of forfrængninger.
% -------------------------------------------------------------------------
Image = Image0;

% --- Forvræng billede. Gaussisk filtrering.
if SigmaGaussBlurr ~= 0
    Image = imgaussfilt(Image, SigmaGaussBlurr); 
end

% --- Tilsæt støjgulv.
if noisefloor > 0 
    temp = noisefloor*max(Image(:))/(1 - noisefloor); % Bestem hæveværdi ud fra den ønskede støjgulvsværdi.
    Image = Image + temp; % Tilføj støjgulv.
    Image = Image/max(Image(:)); % Normaliser.
end

% --- Tilsæt gaussisk støj ovenpå.
if SigmaGaussNoise > 0
    Image = imnoise(Image,'gaussian',0,SigmaGaussNoise); % Tilsæt støj
    Image(Image<noisefloor) = noisefloor; % Min værdi = støjgulv.
    Image(Image>1) = 1; % Erstat for store værdier med 1.
end

% --- Skub de horizontale diffraktioner lidt længere væk (De to gitre diffrakterer måske ikke lige kraftigt.)
if N_disp ~= 0
    N_disp = round(N_disp/2);
    N_diff = round(0.3750*N_cam);
    N_end = round(0.0150*N_cam);
    Image(:,(1:N_diff) + N_end - N_disp) = Image(:,(1:N_diff) + N_end + N_disp); % Forskyd venstre.
    Image(:,-(1:N_diff) + size(Image,2) - N_end + N_disp) = Image(:,-(1:N_diff) + size(Image,2) - N_end - N_disp); % Forskyd venstre.
end

% --- Rotere billedet.
if angle ~= 0
    Image = imrotate(Image,angle,'bilinear','crop');
end


% -------------------------------------------------------------------------
% Virtuel kalibrering.
% -------------------------------------------------------------------------
[i_start,i_MeanCali,i_0_height,i_0_width] = VirtuelCalibration( f,a,h_A,h_cam,N_cam,lambda_l,lambda_u,SigmaCali,NumOfCaliPoints );
N_1 = floor(max(i_MeanCali(:)));
N_0 = length(i_0_height);


% -------------------------------------------------------------------------
% Serialiser diffraktionsbillede.
% -------------------------------------------------------------------------
[g] = SerializeImage_Real( Image,i_0_width,i_0_height,i_start,N_1);

% -------------------------------------------------------------------------
% Opbyg H-matrice for systemet og genskab billede.
% -------------------------------------------------------------------------
% --- Opbyg H-matricen for det optiske system.
[H] = BuildMatrixH_Real_V2(N_wave_estimate,N_0,i_MeanCali);

% --- Estimere det originale billede til serialiseret vektor f.
f = ExpectationMaximation(g,H,N_0,N_0,N_wave_estimate,lambda_l,lambda_u,lambda_l_crop,lambda_u_crop);
EstCube = RebuildDataCube( f,N_0,N_0,N_wave_estimate );
plotCube = DataCube2RGB(EstCube);

% -------------------------------------------------------------------------
% Plot
% -------------------------------------------------------------------------

% Plot diffraktionsmønster
figure
imshow(Image)
title(sprintf('Diffracted picture, %g x %g pixels',N_cam,N_cam))
set(gca,'FontSize',18); % Forstørre textstørrelse

% Plot billede
figure
image(plotCube)
title(sprintf('Estimated picture, %g x %g pixels.',N_0,N_0))
set(gca,'FontSize',18); % Forstørre textstørrelse

% Plot original kube
figure
VisualizeCube(Cube,lambda_l,lambda_u)
set(gca,'FontSize',18); % Forstørre textstørrelse

% Exporter billede
% Export2Gerbil( EstCube,lambda_l,lambda_u )

diary off

