function [rf] = Output(r0,m,wavelength,f,a)
% Funktion for det optiske system.
rf = f(3)*asin(sin(r0/f(2)) + m*wavelength/a);
end



