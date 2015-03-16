function [ upFrac ] = upFracFlow(upWetMobility,upNonMobility)
% This function calculates the horizontal fractional flow

upFrac = upWetMobility ./ (upWetMobility + upNonMobility);

end

