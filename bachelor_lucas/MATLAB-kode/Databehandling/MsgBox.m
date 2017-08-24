function MsgBox( str )
% Udskriveer en besked, med tidspunkt på.
t = clock;
strTime = sprintf('%g:%g:%g',t(4),t(5),t(6));
for i = length(strTime):12
    strTime = [strTime,' '];
end
strTime = [strTime,'>> '];
strTime = [strTime,str];
fprintf('%s\n',strTime)
end

