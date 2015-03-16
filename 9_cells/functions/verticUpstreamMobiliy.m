function [upMobY] = verticUpstreamMobiliy(pressureMatrix,mobilityMatrix)
%This function determines the vertical upstream mobilities

p = pressureMatrix;
mob = mobilityMatrix;

n = size(pressureMatrix);
nRow = n(1); nCol = n(2);

upMobY = zeros(nRow-1,nCol);

for j=1:nCol
    for i=1:nRow-1
        if p(i,j) >= p(i+1,j)
            upMobY(i,j) = mob(i,j);
        else
            upMobY(i,j) = mob(i+1,j);
        end
    end

end

end

