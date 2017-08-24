function [H] = BuildMatrixH_Real_V2(Ns,N_0,i_CaliPoints)
% Opbygger H-matrice for simpel CTIS opstilling.
M = size(i_CaliPoints,1); % Antal bølgelængder i kalibrering.
N_1 = floor(max(i_CaliPoints(:)));

% k- værdier der svarer til bølgelængder fra kalibrering (evenly spaced).
dk = (Ns - 1) / (M - 1);
wave_probe = 1 : dk : Ns;


% -------------------------------------------------------------------------
% Opbyg H-matricen ved brug af interpolation af (virtuelle) målinger.
% -------------------------------------------------------------------------
% --- Bestem start og slut koordinater for de enkelte definerede
% --- bølgelængder i H-matricen, vha. interpolation af målepunkter.. 
N_start = zeros(1,Ns); N_end = N_start;
for k = 1:Ns
    % Find i hvilket interval den valgte bølge er i, i forhold til
        % målepunkterne, og interpolere til position og størrelse.
    for kProbe = 1:M
        if k == wave_probe(kProbe)
            N_start(k) = round(i_CaliPoints(kProbe,1));
            N_end(k) = round(i_CaliPoints(kProbe,2));
            break
        elseif k < wave_probe(kProbe)
            N_start(k) = round(i_CaliPoints(kProbe-1,1) + ...
                (i_CaliPoints(kProbe,1) - i_CaliPoints(kProbe-1,1))* ...
                (k - wave_probe(kProbe - 1))/ ...
                (wave_probe(kProbe) - wave_probe(kProbe - 1)));
            N_end(k) = round(i_CaliPoints(kProbe-1,2) + ...
                (i_CaliPoints(kProbe,2) - i_CaliPoints(kProbe-1,2))* ...
                (k - wave_probe(kProbe - 1))/ ...
                (wave_probe(kProbe) - wave_probe(kProbe - 1)));
            break
        end
    end
end

% For modsat diffraktion.
N_start_mir = N_1 - N_end + 1;
N_end_mir = N_1 - N_start + 1;

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
    end

    % --- H-matrice for venstre orden.
    function [HL] = LeftFirstOrder
        MsgBox('Begin building H-matrix for first left order.')
        HL = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns*5);
        I = eye(N_0); % Opretter identitetsmatrice.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(k) - N_start(k) + 1;
            I_stretch = imresize(I,[(N_stretch), (N_0)],'bilinear');
            % Normaliser sum af hver kolonne til 1.
%             for i = 1:size(I_stretch,2)
%                 I_stretch(:,i) = I_stretch(:,i)/sum(I_stretch(:,i));
%             end
            for i = 1:N_0 % Indsæt for hver række.
                % Indsæt i H-matricen.
                g_index = (i-1)*N_1 + (N_start_mir(k):N_end_mir(k));
                f_index = (k-1)*N_0^2 + ((i-1)*N_0 + 1:i*N_0);
                HL(g_index,f_index) = I_stretch;
            end
        end
        
%         tic
%         HL_old = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns*5);
%         for k = 1:Ns
%             f1 = (k-1)*N_0^2;
%             for i = 1:N_0
%                 g1 = (i-1)*N_1;
%                 f2 = f1 + (i-1)*N_0;
%                 for j = 1:N_0
%                     % Billedet strækkes ud. Omregn j til en tilsvarende
%                     % diffrakteret m.
%                     m = N_start_mir(k) + ...
%                         (N_end_mir(k) - N_start_mir(k)) * ...
%                         (j - 1) / ...
%                         (N_0 - 1);
%                     g_index = g1 + [floor(m) , ceil(m)];
%                     f_index = f2 + j;
%                     HL_old(g_index,f_index) = 1;
%                 end
%             end
%         end
%         toc
    end

    % --- H-matrice for højre orden.
    function [HR] = RightFirstOrder  
        MsgBox('Begin building H-matrix for first right order.')
        HR = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns*5);
        I = eye(N_0); % Opretter identitetsmatrice.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(k) - N_start(k) + 1;
            I_stretch = imresize(I,[(N_stretch), (N_0)],'bilinear');
            % Normaliser sum af hver kolonne til 1.
%             for i = 1:size(I_stretch,2)
%                 I_stretch(:,i) = I_stretch(:,i)/sum(I_stretch(:,i));
%             end
            for i = 1:N_0 % Indsæt for hver række.
                % Indsæt i H-matricen.
                g_index = (i-1)*N_1 + (N_start(k):N_end(k));
                f_index = (k-1)*N_0^2 + ((i-1)*N_0 + 1:i*N_0);
                HR(g_index,f_index) = I_stretch;
            end
        end

%         tic
%         HR_old = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
%     HR_old = zeros(N_0*N_1,N_0^2*Ns);
%         for k = 1:Ns
%             f1 = (k-1)*N_0^2;
%             for i = 1:N_0
%                 g1 = (i-1)*N_1;
%                 f2 = f1 + (i-1)*N_0;
%                 for j = 1:N_0
%                     % Billedet strækkes ud. Omregn j til en tilsvaren
%                     % diffrakteret m.
%                     m = N_start(k) + ...
%                         (N_end(k) - N_start(k)) * ...
%                         (j - 1) / ...
%                         (N_0 - 1);
%                     g_index = g1 + [floor(m) , ceil(m)];
%                     f_index = f2 + j;
%                     HR_old(g_index,f_index) = 1;
%                 end
%             end
%         end
%         toc
    end

    % --- H-matrice for top orden.
    function [HT] = TopFirstOrder    
%         MsgBox('Begin building H-matrix for first top order.')
%         HT = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
%         I = eye(N_0); % Opretter identitetsmatrice for et helt 0.ordens billede.
%         for k = 1:Ns
%             % Stræk I-matricen ud, som defineret under målingerne og interpolation.
%             N_stretch = N_end_mir(k) - N_start_mir(k) + 1;
%             I_stretch_guide = imresize(I,[N_stretch,N_0],'bilinear');
%             f1 = (k-1)*N_0^2;
%             [i_row,i_col] = find(I_stretch_guide == 1);
%             for i = 1:length(i_row)
%                 g_index = (N_start_mir(k)+i_row(i)-2)*N_0 + (1:N_0);
%                 f_index = f1 + (i_col(i)-1)*N_0 + (1:N_0);
%                 HT(g_index,f_index) = I;
%             end
%         end
        MsgBox('Begin building H-matrix for first top order.')
        HT = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
        I = eye(N_0); % Opretter identitetsmatrice for et helt 0.ordens billede.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end_mir(k) - N_start_mir(k) + 1;
            I_stretch_guide = imresize(I,[N_stretch,N_0],'bilinear');
            % Normaliser sum af hver kolonne til 1.
%             for i = 1:size(I_stretch_guide,2)
%                 I_stretch_guide(:,i) = I_stretch_guide(:,i)/sum(I_stretch_guide(:,i));
%             end
            f1 = (k-1)*N_0^2;
            [i_row,i_col] = find(I_stretch_guide ~= 0);
            for i = 1:length(i_row)
                g_index = (N_start_mir(k)+i_row(i)-2)*N_0 + (1:N_0);
                f_index = f1 + (i_col(i)-1)*N_0 + (1:N_0);
                HT(g_index,f_index) = I*I_stretch_guide(i_row(i),i_col(i));
            end
        end
    end

    % --- H-matrice for nedre orden.
    function [HB] = BottomFirstOrder        
        MsgBox('Begin building H-matrix for first bottom order.')
        HB = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
        I = eye(N_0); % Opretter identitetsmatrice for et helt 0.ordens billede.
        for k = 1:Ns
            % Stræk I-matricen ud, som defineret under målingerne og interpolation.
            N_stretch = N_end(k) - N_start(k) + 1;
            I_stretch_guide = imresize(I,[N_stretch,N_0],'bilinear');
            % Normaliser sum af hver kolonne til 1.
%             for i = 1:size(I_stretch_guide,2)
%                 I_stretch_guide(:,i) = I_stretch_guide(:,i)/sum(I_stretch_guide(:,i));
%             end
            f1 = (k-1)*N_0^2;
            [i_row,i_col] = find(I_stretch_guide ~= 0);
            for i = 1:length(i_row)
                g_index = (N_start(k)+i_row(i)-2)*N_0 + (1:N_0);
                f_index = f1 + (i_col(i)-1)*N_0 + (1:N_0);
                HB(g_index,f_index) = I*I_stretch_guide(i_row(i),i_col(i));
            end
        end
 
%         tic
%         HB_old = spalloc(N_0*N_1,N_0^2*Ns,N_0*N_1*Ns);
%         for k = 1:Ns
%             f1 = (k-1)*N_0^2;
%             for i = 1:N_0
%                 % Billedet strækkes ud. Omregn 'i' til en tilsvaren
%                 % diffrakteret m.
%                 m = N_start(k) + ...
%                     (N_end(k) - N_start(k)) * ...
%                     (i - 1) / ...
%                     (N_0 - 1);
%                 m = [floor(m),ceil(m)];
%                 g1 = (m-1)*N_0;
%                 f2 = f1 + (i-1)*N_0;
%                 for j = 1:N_0
%                     g_index = g1 + j;
%                     f_index = f2 + j;
%                     HB_old(g_index,f_index) = 1;
%                 end
%             end
%         end
%         toc
    end

end
