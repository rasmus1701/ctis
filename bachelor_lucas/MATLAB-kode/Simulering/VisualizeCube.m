function VisualizeCube( Cube,lambda_l,lambda_u )
% Opretter en 3D plot, der visualiser kuben i en rummeligt plot.
Ns = size(Cube,3);

% --- Opbyg RGB-billede ved hvert bånd.
dlambda = (lambda_u - lambda_l)/(Ns-1); % Spektral afstand mellem bølgelængder.
waves = lambda_l + (0:(Ns-1))*dlambda;
for k = Ns:-1:1
    TwoDim_slice = zeros(size(Cube,1),size(Cube,2),3);
    for i = 1:size(Cube,1)
        for j = 1:size(Cube,2)
            TwoDim_slice(i,j,:) = wavelength2rgb(waves(k))*Cube(i,j,k);
        end
    end
    RGBslices{k} = TwoDim_slice;
end

% --- Normaliser udsnittende til max = 1.
% Find den maksimale værdi.
maxVal = 0;
for k = 1:Ns
    TwoDim_slice = RGBslices{k};
    if maxVal < max(TwoDim_slice(:));
        maxVal = max(TwoDim_slice(:));
    end
end

% Normaliser.
for k = 1:Ns
    RGBslices{k} = RGBslices{k}/maxVal;
end

% --- Plot udsnittene.
clf
for k = 1:Ns
    alphamap = (rgb2gray(RGBslices{k}) > 0.1)*1;
    h_surface = surface(waves(k)*10^9*ones(size(RGBslices{k},1),size(RGBslices{k},2)),RGBslices{k},'FaceColor','texturemap','EdgeColor','none','CDataMapping','direct',...
        'FaceAlpha','texturemap','AlphaDataMapping','scaled','AlphaData',alphamap);
    if k == 1
        hold on
    end
end
hold off

% --- Udseende af plot.
xlabel('Rummelig x-akse, s_x [pixel]')
ylabel('Rummelig y-akse, s_y [pixel]')
zlabel('Bølgelængde, \lambda [nm]')

set(gca,'color','black') % Ændre baggrund til sort. 
view(-35,45)