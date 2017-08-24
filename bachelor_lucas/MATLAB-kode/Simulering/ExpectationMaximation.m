function [f2] = ExpectationMaximation(g,H,Nx,Ny,Ns,lambda_l,lambda_u,lambda_l_crop,lambda_u_crop)
% Her udnyttes expectation maximation til at genopbygge f vektoren.
% --- Parametre.
MaxNumOfIterations = 50;
MaxError = 2*10^-2;
Edge_crop = 0;

% ---
g = transpose(g);

% --- Første gæt på vektor f.
f1 = transpose(H)*g; % Initialiser f som 1-vektor.
f2 = f1;

% --- Expectation maximation algoritme.
fprintf('\n')
sumH = transpose(sum(H));

for k = 1:MaxNumOfIterations
   MsgBox(sprintf('Start iteration number %g/%g of EM process.',k,MaxNumOfIterations))
    
%     % --- Gem nuværende løsning i en gif.
%     EstCube = RebuildDataCube( f1,Nx,Ny,Ns );
%     hfig = figure;
%     plotCube = DataCube2RGB(EstCube);
%     image(plotCube)
%     title(sprintf('Image number %g.',k))
%     drawnow 
%     frame = getframe(hfig);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if k == 1;
%         imwrite(imind,cm,'ExpectationMaximizationAnimation.gif','gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'ExpectationMaximizationAnimation.gif','gif','WriteMode','append');
%     end
%     close(hfig);
%     
%     % --- Gem nuværende spektrum i en gif.
%     [EstCube,lambda_min,lambda_max] = CropCube(EstCube,lambda_l,lambda_u,lambda_u_crop,lambda_l_crop,Edge_crop);
%     [spectrum,wave] = CubeSpectrum( EstCube,lambda_min,lambda_max );
%     hfig = figure;
%     plot(wave,spectrum)
%     title(sprintf('Image number %g.',k))
%     grid on
%     xlabel('Wavelength [m]')
%     ylabel('Amplitude')
%     ylim([0 1])
%     drawnow 
%     frame = getframe(hfig);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if k == 1;
%         imwrite(imind,cm,'EM_spectrum.gif','gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,'EM_spectrum.gif','gif','WriteMode','append');
%     end
%     close(hfig);
    
    % --- Næste iteration.   
    sumHgHf1 = transpose(H)*(g./(H*f1));
    f2 = f1./sumH .* sumHgHf1;
    
    % --- Test for convergence.
    Error = max(abs(f2 - f1));
    fprintf('Error in this iteration: %g\n\n',Error/max(max([f1, f2])))
    if Error/max(max([f1, f2])) < MaxError
        break
    end
    
    f1 = f2; % Gem den nye vektor f og gentag.
end
MsgBox(sprintf('EM complete.\n\n'))
end

