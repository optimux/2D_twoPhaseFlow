function [arithmeticMean] = arithmeticAverage(vector)
% This function calculate the arithmetic average
%   Detailed explanation goes here

arithmeticMean = zeros(length(vector)-1,1);

for i=1:length(vector)-1
    arithmeticMean(i) = 0.5*(vector(i)+vector(i+1));
end

end

