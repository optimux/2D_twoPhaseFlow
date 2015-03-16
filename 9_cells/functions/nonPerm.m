function [krn] = nonPerm(Siw,Swe,alpha)
% Brooks-Corey correlation for the relative permeability of the
% non-wetting phase
%   This function calculates the relative permeabilities of the non-wetting
%   phase using the Brooks-Corey correlation. In order to calculate the
%   maximum value we must to know Siw (residual saturation of the wetting
%   phase), alpha (the pore size distribution index) and Swe (saturation of
%   the wetting phase) are also neccesaries.

% Calculation of krnmax
krnmax = 1.31 * 2.62*Siw + 1.1*Siw*Siw;

if Siw == 0
    krnmax = 1;
end

if krnmax > 1
    krnmax = 1.0;
end

% Calculation of krn
krn = (krnmax .* (1 - Swe).^2) .* (1 - Swe.^((2+alpha)/alpha));

end

