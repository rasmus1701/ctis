function [ CroppedCube,lambda_min,lambda_max ] = CropCube( Cube,lambda_l,lambda_u,lambda_u_crop,lambda_l_crop,Edge_crop)
% Datakuben sættes ind. Kuben klippes både rummeligt og spektralt
% afhængigt af parameterne.

% Rummelig del der skal klippes.
if Edge_crop ~= 0
    x = round(Edge_crop*size(Cube,2)):round((1-Edge_crop)*size(Cube,2));
    y = round(Edge_crop*size(Cube,1)):round((1-Edge_crop)*size(Cube,1));
else
    x = 1:size(Cube,2);
    y = 1:size(Cube,1);
end

% Spektral del der skal klippes.
dlambda = (lambda_u - lambda_l)/(size(Cube,3)- 1);
k_min = round((lambda_l_crop - lambda_l)/dlambda) + 1;
k_max = round((lambda_u_crop - lambda_l)/dlambda) + 1;
k = k_min:k_max;

% Ny kube
CroppedCube = Cube(y,x,k);

% Med følgende bølgelængder.
lambda_min = lambda_l + dlambda*(k_min - 1);
lambda_max = lambda_l + dlambda*(k_max - 1);

end

