function [H] = BuildMatrixH_Real_V3(Ns,N_0)
% Opbygger H-matrice for simpel CTIS opstilling.
global i_left i_right i_top i_bottom % Alle punkterne laves globale.

M = size(i_left,1); % Antal bølgelængder i kalibrering.

% k- værdier der svarer til bølgelængder fra kalibrering (evenly spaced).
dk = (Ns - 1) / (M - 1);
wave_probe = 1 : dk : Ns;


% -------------------------------------------------------------------------
% Opbyg H-matricen ved brug af interpolation af (virtuelle) målinger.
% -------------------------------------------------------------------------
% --- Bestem start og slut koordinater for de enkelte definerede
% --- bølgelængder i H-matricen, vha. interpolation af målepunkter. 
N_start = zeros(4,Ns); N_end = N_start; % Række1: venstre diff, række2: højrediff, række3: øvre diff, røkke4: nedre diff.
for P = 1:4 % Indeks for 1. ordens prjektioner.
    for k = 1:Ns % Indeks for bøglelængde i datakube.
        switch P
            case 1 % Vesntre diffraktion.
                N_start(P,k) = interp1(wave_probe,i_left(:,1),k);
                N_end(P,k) = interp1(wave_probe,i_left(:,2),k);
            case 2 % Højre diffraktion.
                N_start(P,k) = interp1(wave_probe,i_right(:,1),k);
                N_end(P,k) = interp1(wave_probe,i_right(:,2),k);
            case 3 % Top diffraktion.
                N_start(P,k) = interp1(wave_probe,i_top(:,1),k);
                N_end(P,k) = interp1(wave_probe,i_top(:,2),k);
            case 4 % Bund diffraktion.
                N_start(P,k) = interp1(wave_probe,i_bottom(:,1),k);
                N_end(P,k) = interp1(wave_probe,i_bottom(:,2),k);
        end
    end
end

% Afrunding af koordinaterne..
N_start = round(N_start);
N_end = round(N_end);

% --- Opbyg H-matricen ud fra de definerede punkter.
fprintf('\n')
H = [ZeroOrder;LeftFirstOrder;RightFirstOrder;TopFirstOrder;BottomFirstOrder];

MsgBox('H-matrix construction completed.')


% =========================================================================
% Nested sub-functions.
% =========================================================================
    function [HZ] = ZeroOrder
        MsgBox('Begin building H-matrix for zero order.')
        % Opbygger H-matrice for 0. ordens diffraktion.
        I = speye(N_0^2);
        HZ = repmat(I,[1,Ns]);
        MsgBox(sprintf('Size of zero order H-matrix: %g x %g',size(HZ,1),size(HZ,2)))
    end

    % --- H-matrice for venstre orden.
    function [HL] = LeftFirstOrder
        MsgBox('Begin building H-matrix for first left order.')
        N_1 = max(i_left(:)); % Diffraktionens størrelse.
        HL = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns*5);
        I = eye(N_0); % Opretter identitetsmatrice.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(1,k) - N_start(1,k) + 1;
            I_stretch = imresize(I,[(N_stretch), (N_0)],'bilinear');
            for i = 1:N_0 % Indsæt for hver række.
                % Indsæt i H-matricen.
                g_index = (i-1)*N_1 + N_1 - (N_end(1,k):-1:N_start(1,k)) + 1;
                f_index = (k-1)*N_0^2 + ((i-1)*N_0 + 1:i*N_0);
                HL(g_index,f_index) = I_stretch;
            end
        end
        MsgBox(sprintf('Size of left H-matrix: %g x %g',size(HL,1),size(HL,2)))
    end

    % --- H-matrice for højre orden.
    function [HR] = RightFirstOrder  
        MsgBox('Begin building H-matrix for first right order.')
        N_1 = max(i_right(:)); % Diffraktionens størrelse.
        HR = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns*5);
        I = eye(N_0); % Opretter identitetsmatrice.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(2,k) - N_start(2,k) + 1;
            I_stretch = imresize(I,[(N_stretch), (N_0)],'bilinear');
            for i = 1:N_0 % Indsæt for hver række.
                % Indsæt i H-matricen.
                g_index = (i-1)*N_1 + (N_start(2,k):N_end(2,k));
                f_index = (k-1)*N_0^2 + ((i-1)*N_0 + 1:i*N_0);
                HR(g_index,f_index) = I_stretch;
            end
        end
        MsgBox(sprintf('Size of right H-matrix: %g x %g',size(HR,1),size(HR,2)))
    end

    % --- H-matrice for top orden.
    function [HT] = TopFirstOrder    
        MsgBox('Begin building H-matrix for first top order.')
        N_1 = max(i_top(:)); % Diffraktionens størrelse.
        HT = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
        I = eye(N_0); % Opretter identitetsmatrice for et helt 0.ordens billede.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(3,k) - N_start(3,k) + 1;
            I_stretch_guide = imresize(I,[N_stretch,N_0],'bilinear');
            f1 = (k-1)*N_0^2;
            [i_row,i_col] = find(I_stretch_guide ~= 0);
            for i = 1:length(i_row)
                g_index = (N_1 - N_end(3,k) + i_row(i) - 1)*N_0 + (1:N_0);
                f_index = f1 + (i_col(i)-1)*N_0 + (1:N_0);
                HT(g_index,f_index) = I*I_stretch_guide(i_row(i),i_col(i));
            end
        end
        MsgBox(sprintf('Size of top H-matrix: %g x %g',size(HT,1),size(HT,2)))
    end

    % --- H-matrice for nedre orden.
    function [HB] = BottomFirstOrder        
        MsgBox('Begin building H-matrix for first bottom order.')
        N_1 = max(i_bottom(:)); % Diffraktionens størrelse.
        HB = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
        I = eye(N_0); % Opretter identitetsmatrice for et helt 0.ordens billede.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(4,k) - N_start(4,k) + 1;
            I_stretch_guide = imresize(I,[N_stretch,N_0],'bilinear');
            f1 = (k-1)*N_0^2;
            [i_row,i_col] = find(I_stretch_guide ~= 0);
            for i = 1:length(i_row)
                g_index = (N_start(4,k)+i_row(i)-2)*N_0 + (1:N_0);
                f_index = f1 + (i_col(i)-1)*N_0 + (1:N_0);
                HB(g_index,f_index) = I*I_stretch_guide(i_row(i),i_col(i));
            end
        end
        MsgBox(sprintf('Size of bottom H-matrix: %g x %g',size(HB,1),size(HB,2)))
    end

end
