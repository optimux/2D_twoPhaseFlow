function [ krw] = wetPerm(Swe,alpha)
% Brooks-Corey correlation for relative permeabilty of wettting phase 
%   This function calculaltes the relative permeabiltiy of the wetting
%   phase using the Brooks-Corey correlation, the inputs are Swe (the
%   effective saturation of the wetting phase) ande alpha (the pore size
%   distribution index)

krw = Swe .^ ((2+3*alpha)/alpha);

end

