function [ Image ] = SimulateSystemV3( Cube, N_cam, lambda_l,lambda_u,f,a,h_A,h_cam,boolCamRespons,boolLightSource)
% Her simuleres det optiske system. Der outputtes et forventet billede på
% kamera.
% --- Størrelse af original billede.
Size = size(Cube);
Nx = Size(1);Ny = Size(2); Ns = Size(3);
s_o = (2*h_A)./(Nx); % Bestem afstand mellem pixler.
dlambda = (lambda_u - lambda_l)/(Ns-1); % Spektral afstand mellem bølgelængder.

% --- Størrelse af kamera.
Image = zeros(N_cam);
s_i = (2*h_cam)./(N_cam); % Bestem afstand mellem pixler.

fprintf('\n')
for k = 1:Ns % Udvælg bølgelængde.
    MsgBox(sprintf('Start simulation for wavelength %g/%g.',k,Ns))
    wavelength = (k-1)*dlambda + lambda_l; % Den valgte bølgelængde.
    
    % Bestem modifiers for intensitet.
    IntensityModifier = 1;
    if boolCamRespons % Skal kameraets respons medregnes?
        IntensityModifier = IntensityModifier * CamResponse(wavelength);
    end
    if boolLightSource % Skal Lyskildens spektrum medregnes?
        IntensityModifier = IntensityModifier * LightSourceSpectrum(wavelength);
    end
    
    % --- Simuler for den valgte bølgelængde.
    for i = 1:Nx % x-pixel.
        for j = 1:Ny % y-pixel.
            if Cube(i,j,k) == 0
                continue % Tom voxel.
            end

            % --- Bestem (x,y) koordinator ved blænden.
            r0 = ([i,j]-0.5)*s_o - h_A;

            % --- Bestem tilhørende koordinater på kamera inden for dens
            % --- overflade. Dette sker ved at finde koordinater for
            % --- "skyggen" en pixel med en størrelse s_o^2 den efterlader
            % --- på kamera.
            % 0. orden:
            rf(1,:) = Output(r0 + [-s_o,-s_o]/2,[0,0],wavelength,f,a);
            rf(2,:) = Output(r0 + [s_o,s_o]/2,[0,0],wavelength,f,a);
            xf = transpose(rf(:,1));yf = transpose(rf(:,2));

            % Ordner hvor mx > 0.
            mx = 1;
            x(1) = Output(r0(1)-s_o/2,mx,wavelength,f,a);
            x(2) = Output(r0(1)+s_o/2,mx,wavelength,f,a);
            while min(abs(x)) <= h_cam
                xf = [xf, x];
                mx = mx + 1;
                x(1) = Output(r0(1)-s_o,mx,wavelength,f,a);
                x(2) = Output(r0(1)+s_o,mx,wavelength,f,a);
            end

            % Ordner hvor mx < 0.
            mx = -1;
            x(1) = Output(r0(1)-s_o/2,mx,wavelength,f,a);
            x(2) = Output(r0(1)+s_o/2,mx,wavelength,f,a);
            while min(abs(x)) <= h_cam
                xf = [xf, x];
                mx = mx - 1;
                x(1) = Output(r0(1)-s_o/2,mx,wavelength,f,a);
                x(2) = Output(r0(1)+s_o/2,mx,wavelength,f,a);
            end

            % Ordner hvor my > 0.
            my = 1;
            y(1) = Output(r0(2)-s_o/2,my,wavelength,f,a);
            y(2) = Output(r0(2)+s_o/2,my,wavelength,f,a);
            while min(abs(y)) <= h_cam
                yf = [yf, y];
                my = my + 1;
                y(1) = Output(r0(2)-s_o/2,my,wavelength,f,a);
                y(2) = Output(r0(2)+s_o/2,my,wavelength,f,a);
            end

            % Ordner hvor my < 0.
            my = -1;
            y(1) = Output(r0(2)-s_o/2,my,wavelength,f,a);
            y(2) = Output(r0(2)+s_o/2,my,wavelength,f,a);
            while min(abs(y)) <= h_cam
                yf = [yf, y];
                my = my - 1;
                y(1) = Output(r0(2)-s_o/2,my,wavelength,f,a);
                y(2) = Output(r0(2)+s_o/2,my,wavelength,f,a);
            end

            % Omregn koordinator til pixler på kamera og indsæt i image
            % matrice. Koordinater der ligger mellem pixler, der vægtes
            % intensiteten til de 4 omkringliggende pixler, afhængigt at
            % afstanden til pixlen.
            for ii = 2:2:length(xf)
                for jj = 2:2:length(yf)
                    % Find skyggen for diffraktion.
                    x = [xf(ii-1),xf(ii)];
                    y = [yf(jj-1),yf(jj)];
                    % Tilsvarende indeks på kamera.
                    m = (x + h_cam)/s_i + 0.5;
                    n = (y + h_cam)/s_i + 0.5;
                    % Intensitet pr. pixel.
                    ShadowArea = abs(m(1)-m(2))*abs(n(1)-n(2)); % Størrelsen af skyggen målt i indeks.
                    PixelIntensity = Cube(i,j,k)/ShadowArea; % Intensitet per pixel.
                    
                    % Udfyld de ramte pixels. Ved delvist overlappede
                    % pixler, der vægtes intensiteten i forhold til hvor
                    % tæt på pixlen er.
                    for iii = round(m(1)):round(m(2))
                        % Test om indeks ligger inden for 'Image'
                        if iii < 1 || iii > N_cam
                            % Pixel 'out of range'.
                            continue
                        end
                        % Overlap i x-retning.
                        if round(m(1)) == round(m(2))
                            % Skyggen er meget lille og inden for samme
                            % pixel.
                            factorX = m(2) - m(1);
                        elseif iii < m(1) + 0.5
                            % Der er delvis overlap i x-retning. Bestem
                            % vægntning.
                            factorX = iii - m(1) + 0.5;
                        elseif iii > m(2) - 0.5
                            % Der er delvis overlap i x-retning. Bestem
                            % vægntning.
                            factorX = m(2) - iii + 0.5;
                        else
                            % Ingen delvis overlap.
                            factorX = 1;
                        end
                        for jjj = round(n(1)):round(n(2))
                            % Test om indeks ligger inden for 'Image'
                            if jjj < 1 || jjj > N_cam
                                % Pixel 'out of range'.
                                continue
                            end
                            % Overlap i y-retning.
                            if round(n(1)) == round(n(2))
                                % Skyggen er meget lille og inden for samme
                                % pixel.
                                factorY = n(2) - n(1);
                            elseif jjj < n(1) + 0.5
                                % Der er delvis overlap i y-retning. Bestem
                                % vægntning.
                                factorY = jjj - n(1) + 0.5;
                            elseif jjj > n(2) - 0.5
                                % Der er delvis overlap i y-retning. Bestem
                                % vægntning.
                                factorY = n(2) - jjj + 0.5;
                            else
                                % Ingen delvis overlap.
                                factorY = 1;
                            end
                            % Indsæt intensitet.
                            Image(iii,jjj) = Image(iii,jjj) + PixelIntensity * factorX * factorY * IntensityModifier;
                        end
                    end
                end
            end        
        end
    end
end

% Normaliser.
Image = Image/max(Image(:));

MsgBox('Simulation complete.')
end

