function [ Swe ] = effectSat(Sw, Siw)
%This function calculate the effective saturation 
% This function calculate the effective saturation given the residiual
% saturation Siw and the saturation of the wetting phase Sw

Swe = (Sw - Siw) ./ (1.0 - Siw);

end

