function [darVel] = darcyVelocity(harmPerm,haMob,pressure,sptlstep,density,angle)
%This function calculates the non-wetting phase velocity

n=length(pressure); %length of pressure vector
gravity=9.81; %gravity acceleration
darVel = zeros(n-1,1);
for i=1:n-1
    darVel(i)=-harmPerm(i)*haMob(i)*(((pressure(i+1)-pressure(i))/sptlstep)...
        +density*gravity*sin(angle));
end
end

