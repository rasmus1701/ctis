function [rgb] = wavelength2rgb(Wavelength)
% Converts an optical wavelength to a corresponding RGB code

Wavelength = Wavelength*10^9;

if Wavelength <= 439 && Wavelength >= 380
    r = -(Wavelength - 440) / (440 - 380);
    g = 0.0;
    b = 1.0;
elseif Wavelength >= 440 && Wavelength <= 489
    r = 0.0;
    g = (Wavelength - 440) / (490 - 440);
    b = 1.0;
elseif Wavelength >= 490 && Wavelength <= 509
    r = 0.0;
    g = 1.0;
    b = -(Wavelength - 510) / (510 - 490);
elseif Wavelength >= 510 && Wavelength <= 579
    r = (Wavelength - 510) / (580 - 510);
    g = 1.0;
    b = 0.0;
elseif Wavelength >= 580 && Wavelength <= 644
    r = 1.0;
    g = -(Wavelength - 645) / (645 - 580);
    b = 0.0;
elseif Wavelength >= 645 && Wavelength <= 780
    r = 1.0;
    g = 0.0;
    b = 0.0;
else
    r = 0.0;
    g = 0.0;
    b = 0.0;
end
      
% Let the intensity fall off near the vision limits
if Wavelength >= 380 && Wavelength <= 419
    factor = 0.3 + 0.7*(Wavelength - 380) / (420 - 380);
elseif Wavelength >= 420 && Wavelength <= 700
    factor = 1.0;
elseif Wavelength >= 701 && Wavelength <= 780
    factor = 0.3 + 0.7*(780 - Wavelength) / (780 - 700);
else
    factor = 0.0;
end
rgb = [r,g,b]*factor;

end

