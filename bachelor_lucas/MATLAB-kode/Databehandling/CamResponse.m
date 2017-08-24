function [ f ] = CamResponse(x)
% Respons for kamera.
QuantumEfficiency = [0.551528, ... 
0.609734, ... 
0.579436, ... 
0.657477, ... 
0.629763, ... 
0.683589, ... 
0.715805, ... 
0.747327, ... 
0.785255, ... 
0.750947, ... 
0.730194, ... 
0.785366, ... 
0.799759, ... 
0.884546, ... 
0.840136, ... 
0.850072, ... 
0.914025, ... 
0.896265, ... 
0.863926, ... 
0.917842, ... 
0.981127, ... 
0.927428, ... 
0.93743, ... 
0.956911, ... 
0.895039, ... 
0.872746, ... 
0.912744, ... 
0.912338, ... 
0.955445, ... 
0.929907, ... 
0.897143, ... 
0.929551, ... 
0.973053, ... 
0.930565, ... 
0.907925, ... 
0.923887, ... 
0.941302, ... 
0.981691, ... 
0.972499, ... 
0.876467, ... 
0.856708, ... 
0.938776, ... 
0.993033, ... 
0.936148, ... 
0.878785, ... 
0.882032, ... 
0.9038, ... 
0.92521, ... 
0.980056, ... 
1, ... 
0.940715, ... 
0.86819, ... 
0.854309, ... 
0.91368, ... 
0.950958, ... 
0.900341, ... 
0.829726, ... 
0.773207, ... 
0.779511, ... 
0.763124, ... 
0.785336, ... 
0.805473, ... 
0.856459, ... 
0.889436, ... 
0.833363, ... 
0.775039, ... 
0.737254, ... 
0.737323, ... 
0.803312, ... 
0.832532, ... 
0.826716, ... 
0.797891, ... 
0.742606, ... 
0.698578, ... 
0.700491, ... 
0.702363, ... 
0.686317, ... 
0.676142, ... 
0.680372, ... 
0.694376, ... 
0.700768, ... 
0.672683, ... 
0.588918, ... 
0.551818, ... 
0.515532, ... 
0.514361, ... 
0.51838, ... 
0.525657, ... 
0.548879, ... 
0.549924, ... 
0.532892, ... 
0.481038, ... 
0.433543, ... 
0.409531, ... 
0.385472, ... 
0.387395, ... 
0.386887, ... 
0.366988, ... 
0.364321, ... 
0.33334, ... 
0.330622, ... 
0.344902, ... 
0.343489, ... 
0.3407, ... 
0.307167, ... 
0.270854, ... 
0.230825, ... 
0.212679, ... 
0.175329, ... 
0.176261, ... 
0.16196, ... 
0.161772, ... 
0.152728, ... 
0.134103, ... 
0.136321, ... 
0.143637, ... 
0.124617, ... 
0.108533, ... 
0.0891888, ... 
0.082943, ... 
0.0578627];

wavelength = [4e-07, ... 
4.05e-07, ... 
4.1e-07, ... 
4.15e-07, ... 
4.2e-07, ... 
4.25e-07, ... 
4.3e-07, ... 
4.35e-07, ... 
4.4e-07, ... 
4.45e-07, ... 
4.5e-07, ... 
4.55e-07, ... 
4.6e-07, ... 
4.65e-07, ... 
4.7e-07, ... 
4.75e-07, ... 
4.8e-07, ... 
4.85e-07, ... 
4.9e-07, ... 
4.95e-07, ... 
5e-07, ... 
5.05e-07, ... 
5.1e-07, ... 
5.15e-07, ... 
5.2e-07, ... 
5.25e-07, ... 
5.3e-07, ... 
5.35e-07, ... 
5.4e-07, ... 
5.45e-07, ... 
5.5e-07, ... 
5.55e-07, ... 
5.6e-07, ... 
5.65e-07, ... 
5.7e-07, ... 
5.75e-07, ... 
5.8e-07, ... 
5.85e-07, ... 
5.9e-07, ... 
5.95e-07, ... 
6e-07, ... 
6.05e-07, ... 
6.1e-07, ... 
6.15e-07, ... 
6.2e-07, ... 
6.25e-07, ... 
6.3e-07, ... 
6.35e-07, ... 
6.4e-07, ... 
6.45e-07, ... 
6.5e-07, ... 
6.55e-07, ... 
6.6e-07, ... 
6.65e-07, ... 
6.7e-07, ... 
6.75e-07, ... 
6.8e-07, ... 
6.85e-07, ... 
6.9e-07, ... 
6.95e-07, ... 
7e-07, ... 
7.05e-07, ... 
7.1e-07, ... 
7.15e-07, ... 
7.2e-07, ... 
7.25e-07, ... 
7.3e-07, ... 
7.35e-07, ... 
7.4e-07, ... 
7.45e-07, ... 
7.5e-07, ... 
7.55e-07, ... 
7.6e-07, ... 
7.65e-07, ... 
7.7e-07, ... 
7.75e-07, ... 
7.8e-07, ... 
7.85e-07, ... 
7.9e-07, ... 
7.95e-07, ... 
8e-07, ... 
8.05e-07, ... 
8.1e-07, ... 
8.15e-07, ... 
8.2e-07, ... 
8.25e-07, ... 
8.3e-07, ... 
8.35e-07, ... 
8.4e-07, ... 
8.45e-07, ... 
8.5e-07, ... 
8.55e-07, ... 
8.6e-07, ... 
8.65e-07, ... 
8.7e-07, ... 
8.75e-07, ... 
8.8e-07, ... 
8.85e-07, ... 
8.9e-07, ... 
8.95e-07, ... 
9e-07, ... 
9.05e-07, ... 
9.1e-07, ... 
9.15e-07, ... 
9.2e-07, ... 
9.25e-07, ... 
9.3e-07, ... 
9.35e-07, ... 
9.4e-07, ... 
9.45e-07, ... 
9.5e-07, ... 
9.55e-07, ... 
9.6e-07, ... 
9.65e-07, ... 
9.7e-07, ... 
9.75e-07, ... 
9.8e-07, ... 
9.85e-07, ... 
9.9e-07, ... 
9.95e-07, ... 
1e-06];


f = interp1(wavelength,QuantumEfficiency,x);
    
end

