function [gaussfield,zinnharvey1,zinnharvey2] = permGenerator(gridSize,average,variance,intLongDir,intTranDir)
% Zinn and Harvey 2003 Multivariate log-gaussian correlation
% http://onlinelibrary.wiley.com/doi/10.1029/2001WR001146/full

nx = gridSize;
avg = average;
sill = variance;
lx = intLongDir;
ly = intTranDir;

[X,Y] = meshgrid(-nx/2:1:(nx-1)/2);

ntot = nx^2;

dis=sqrt((X/lx).^2 + (Y/ly).^2);

covgauss=exp(-dis.^2*pi/4);

C=fftshift(covgauss);

S=fftn(C)/ntot;
S=abs(S);

S(1,1) = 0;

r1 = sqrt(S).*exp(1i*angle(fftn(rand(nx,nx))));

gaussfield = real(ifftn(r1*ntot));

zinnharvey1=-erfinv(2*erf(abs(gaussfield)*sqrt(0.5))-1)*sqrt(2);
zinnharvey2=erfinv(2*erf(abs(gaussfield)*sqrt(0.5))-1)*sqrt(2);

gaussfield=sqrt(sill)*gaussfield+avg;
zinnharvey1=sqrt(sill)*zinnharvey1+avg;
zinnharvey2=sqrt(sill)*zinnharvey2+avg;
figure(1),pcolor(gaussfield);
shading interp
colorbar
figure(2),pcolor(zinnharvey1);
shading interp
colorbar
figure(3),pcolor(zinnharvey2);
shading interp
colorbar

% figure(11),pcolor(gaussfield(1:30,:));

end

