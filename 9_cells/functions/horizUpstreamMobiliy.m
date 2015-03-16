function [upMobX] = horizUpstreamMobiliy(pressureMatrix,mobilityMatrix)
%This function determines the horizontal upstream mobilities

p = pressureMatrix;
mob = mobilityMatrix;

n = size(pressureMatrix);
nRow = n(1); nCol = n(2);

upMobX = zeros(nRow,nCol-1);

for i=1:nRow
    for j=1:nCol-1
        if p(i,j) >= p(i,j+1)
            upMobX(i,j) = mob(i,j);
        else
            upMobX(i,j) = mob(i,j+1);
        end
    end

end

end

