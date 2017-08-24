function Export2Gerbil( Cube,lambda_min,lambda_max )
% Exporterer en hyperspektral datakube til gerbil formatet.

% Parametre:
wave_min = lambda_min*10^9; % Mindste bølgelængde i kuben.
wave_max = lambda_max*10^9; % Højeste bølgelængde i kuben.

dwave = (wave_max - wave_min)/(size(Cube,3) - 1);
waves = (wave_min:dwave:wave_max);
% waves = round(waves);

% Sti:
strFolder = 'Export2Gerbil';
strSubFolder = 'images';
strGEBname = ['CTIS','.geb'];

% Normaliser og konverter til uint8.
Cube = Cube/max(Cube(:));
uint16Cube = uint16(round(Cube*65535));

% Slet gammel mappe
[status, message, messageid] = rmdir('Export2Gerbil','s');
if ~status && strcmp(messageid,'MATLAB:RMDIR:NotADirectory')
    warning(message)
end

% Opret mapper.
mkdir([strFolder,'\'],[strSubFolder,'\']);

% Exporter billede
strFileName{size(Cube,3)} = ' '; % Opret array med strings.
for i = 1:size(Cube,3)
    strFileName{i} = sprintf('wave_%g.png',waves(i));
    strFullPath = [strFolder,'\',strSubFolder,'\',strFileName{i}];
    imwrite(uint16Cube(:,:,i),strFullPath,'BitDepth',16)
end

% Opret *.GEB string.
strGEB = [num2str(size(Cube,3)), ' ', strSubFolder,'/',sprintf('\n')];
for i = 1:size(Cube,3)
    strGEB = [strGEB, strFileName{i}, sprintf(' %g\n',waves(i))];
end

% Opret *.GEB fil.
fileID = fopen([strFolder,'\',strGEBname],'w');
fprintf(fileID,strGEB);
fclose(fileID);