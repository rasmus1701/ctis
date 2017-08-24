function [ out ] = CorrectError( Cube,lambda_l,lambda_u )
% Kamneraets spektrale fejl korrigeres.
dlambda = (lambda_u - lambda_l) / (size(Cube,3) - 1);
lambda = lambda_l:dlambda:lambda_u;

% Udfør korrektion.
for k = 1:size(Cube,3)
    Cube(:,:,k) = Cube(:,:,k)/CamResponse(lambda(k)); % Korriger fejl.
end

% Normaliser.
out = Cube/max(Cube(:));

end

