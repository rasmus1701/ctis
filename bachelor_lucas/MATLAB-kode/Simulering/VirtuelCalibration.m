function [i_start,i_MeanCali,i_0_height,i_0_width] = VirtuelCalibration( f,a,h_A,h_cam,N_cam,lambda_l,lambda_u,sigma,NumOfCaliPoints )
% Bestemmer m�lepunkter for kalibrering af systemet, til senere bestemmelse
% af serialiseret udsk�ringer og H-matrice. 'sigma' angiver usikkerheden af
% m�lepunkterne.

% --- Bestem st�rrelsen af 0. orden.
h_0 = abs(Output(h_A,0,lambda_l,f,a)); % H�jden af f�rsteordensbillede.
s_I = h_cam*2/(N_cam); % Afsand mellem pixler p� kamera.
if sigma > 0
    N_h0 = ceil(h_0/s_I + normrnd(0,sigma/10)); % H�jden i antal pixler p� 0. orden. (+ st�j)
else
    N_h0 = ceil(h_0/s_I); % H�jden i antal pixler p� 0. orden.
end
i_0_height = ((-N_h0+1):N_h0) + round(N_cam/2);
i_0_width = i_0_height;

% --- Opbyg m�lepunkter for M (virtuelle) m�linger.
dlambdaProbe = (lambda_u - lambda_l) / (NumOfCaliPoints - 1);
i_MeanCali = zeros(NumOfCaliPoints,2); % Indeholder indeks for �vre og nedre diffraktion for hver b�lgel�ngde.
lambdaProbe = lambda_l : dlambdaProbe : (lambda_l + dlambdaProbe*(NumOfCaliPoints-1));

% --- Bestem (x,y)-koordinater for ekstremerne i 1. orden.
h_low = Output(-h_A,1,lambdaProbe,f,a); % �vre h�jde for diffraktion.
h_up = Output(h_A,1,lambdaProbe,f,a); % �vre h�jde for diffraktion.


% --- Bestem tilsvarende pixel.
% Bestem reference 
% Indeks for alle m�lepunkter i forhold til referencen.
i_MeanCali(:,1) = h_low/s_I; % Gem position.
i_MeanCali(:,2) = h_up/s_I; % Gem position.

% --- Tilf�j st�j til disse m�linger.
if sigma > 0
    for i = 1:numel(i_MeanCali)
        i_MeanCali(i) = i_MeanCali(i) + normrnd(0,sigma) ;      
    end
end

% --- Afrund m�lingerne.
i_MeanCali(:) = ceil(i_MeanCali(:));

% --- Start af f�rste pixel i diffraktion.
i_start = i_MeanCali(1,1)*ones(4,1);
i_start(1) = round(N_cam/2 + round(normrnd(0,sigma))) - i_start(1);
i_start(2) = round(N_cam/2 + round(normrnd(0,sigma))) + i_start(2);
i_start(3) = round(N_cam/2 + round(normrnd(0,sigma))) - i_start(3);
i_start(4) = round(N_cam/2 + round(normrnd(0,sigma))) + i_start(4);

% --- Kalibrering i forhold til start.
i_MeanCali = i_MeanCali - i_MeanCali(1) + 1;


end

