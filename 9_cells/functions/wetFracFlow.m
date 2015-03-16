function [fractional] = wetFracFlow(upstrWetMobility,upstrNonMobility)
%This function calculates the fractional flow

n=length(upstrWetMobility);
fractional=zeros(1,n);
for i=1:n
    fractional(i)= upstrWetMobility(i)/ ...
                   (upstrWetMobility(i)+upstrNonMobility(i));
end
end

