function [ g] = SerializeImage_Real( Image,i_0_width,i_0_height,i_start,N_1)
% Her opbygges en serialiseret vektor af diffraktionsm�nsteret. For at
% spare p� RAM og beregningstid, s� udv�lges kun de pixler, hvor der er 0.
% ordens samt 1. ordens vertikale og horisontale diffraktioner.
% Den serialiserede vector er opbygget p� den her m�de:
% g = [(0,0) (-1,0) (1,0) (0,-1) (0,1)] -> Fordeling af de forskellige ordner.
% Ved hver sektion er opbygningen: p((j-1)*length(i) + i) = Image(i,j)

% N_cam_center = N_cam/2 + 0.5;


% --- 0. Ordens diffraktion.
fprintf('\n')
MsgBox('Begin serialize zero order.')
% Indl�s 0. ordens diffraktion.
Image_select = Image(i_0_height,i_0_width); % Indl�s 0. ordens billede.
g_0 = serialize(Image_select); % Serialiser.
figure;imshow(Image_select)
title('Zero order')


% --- Indl�s f�rste ordens diffraktion.
MsgBox('Begin serialize first order.')
MsgBox('Left order.')
% Venstre horisontale diffraktioner.
i_end = i_start(1) - N_1 + 1;
Image_select = Image(i_0_height,i_end:i_start(1));
g_left = serialize(Image_select); % Serialiser.
figure;imshow(Image_select)
title('Left order')


MsgBox('Right order.')
% H�jre horisontale diffraktioner.
i_end = i_start(2) + N_1 - 1;
Image_select = Image(i_0_height,i_start(2):i_end);
g_right = serialize(Image_select); % Serialiser.
figure;imshow(Image_select)
title('Right order')


MsgBox('Top order.')
% �vre vertikale diffraktioner.
i_end = i_start(3) - N_1 + 1;
Image_select = Image(i_end:i_start(3),i_0_width);
g_top = serialize(Image_select); % Serialiser.
figure;imshow(Image_select)
title('Top order')

MsgBox('Bottom order.')
% Nedre vertikale diffraktioner.
i_end = i_start(4) + N_1 - 1;
Image_select = Image(i_start(4):i_end,i_0_width);
g_bottom = serialize(Image_select); % Serialiser.
figure;imshow(Image_select)
title('Bottom order')

% --- Udj�vn "energien" i hvert udsnit.
MsgBox('Adjust image energies.')
% Sum af alle diffraktioner.
sum0 = sum(g_0(:));
sumleft = sum(g_left(:));
sumright = sum(g_right(:));
sumtop = sum(g_top(:));
sumbottom = sum(g_bottom(:));

% F�rst skaleres 0. orden til max (1,00).
g_0 = g_0/max(g_0(:));
sum0 = sum(g_0(:));

% Summen af alle billeder bruges og skaleres til at v�re ens med 0.
% orden.
g_left = g_left*sum0/sumleft;
g_right = g_right*sum0/sumright;
g_top = g_top*sum0/sumtop;
g_bottom = g_bottom*sum0/sumbottom;

% Saml til en g vektor.
g = [g_0,g_left,g_right,g_top,g_bottom];

MsgBox('Serialization complete.')

end

% =========================================================================
% Sub-functions
% =========================================================================
function output = serialize(Image2D)
    output = zeros(1,numel(Image2D));
    ImageDimension = size(Image2D);
    for i = 1:ImageDimension(1)
        for j = 1:ImageDimension(2)
            output((i-1)*ImageDimension(2) + j) = Image2D(i,j);
        end
    end
end
