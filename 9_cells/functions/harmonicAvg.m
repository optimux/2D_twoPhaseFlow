function [harmVector] = harmonicAvg(vector)
%This function calculates the harmonic average for a uniform grid.
%   Given a vector, this function calculates the harmonic average
%   between the elements inside of it.

n = length(vector);
harmVector = zeros(1,n-1);

for i=1:n-1
    harmVector(i) = 2./((1/vector(i))+(1/vector(i+1)));
end

end
