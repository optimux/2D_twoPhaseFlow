%  Script = Two-dimensional, single-phase, steady-state flow 
%           in heterogeneous porous media including gravity.
%
%                >> Final version date: 2015.03.04 <<
%  
%  PDE'S involved: 
%       1. Conservation of mass of the fluid: -div(u) = 0        
%       2. Darcy's Law (pressure + gravity): u = -(k/mu) grad(p - rho*g*z)
%
%  Discretization: Finite Volume Method. The gradientes have been 
%                  approximated via TPFA (Two-Points Flux Approximation).
%  
%  The system: Consist in a x-y plane, where the x coordinate represents
%              the horizontal direction and the y coordinate represents
%              the vertical direction. The origin of the system is the
%              point 1,1 (Top-Left Corner), where the elevation is max.
%              The y-coordinate increases downwards and the x-coordinate
%              increases from left to right.
%  
%   Boundary Conditions:
%       * Top and bottom borders of the system are imperbeable, thus
%         u_top = 0 and u_bottom = 0 for any x-position.
%       * Left and right borders have been sets as constant pressure, 
%         where the value of the pressure is determined through the 
%         condition: grad(potential_y) = 0. As the elevation changes in
%         vertical direction, the pressure must change in order to 
%         satisfy the BC. The consecuence of this type of is that the 
%         vertical velocity will be null.
%
%   Expected results = The flux potential must vary along the x-coordinate,
%                      but remain constant along the y-coordinate.
%
%   Author: Jhabriel Varela, Ch.E. >> jhabriel@gmail.com
%   University: Universidad Paraguayo-Alemana
%   City: Asuncion -- Paraguay
%

%% Physical parameters
visWet = 1.1875;                    % [Pa.s] Viscos. of wph  ~ H2O = 1.1875
visNon = 0.0577;                    % [Pa.s] Viscos. of nwph ~ CO2 = 0.0577
denWet = 1121;                      % [kg/m3] Density of wph  ~ H2O = 1121
denNon = 714;                       % [kg/m3] Density of nwph ~ CO2 = 714
Siw = 0;                            % [-] Residual wet. phase saturation ~ 0
por = 0.10;                         % [-] Rock porosity ~ .10
alpha = 2.0;                        % [-] Pore size distribution index ~ 2

% Spatial Parameters
Lx = 10;                             % [m] horizontal length
Ly = 10;                             % [m] vertical length
nx = 32;                             % number of horizontal cells
inx = nx-2;                         % number of internal horizontal cells
ny = 30;                             % number of vertical cells = number of internal vertical cells
dx = Lx/(nx-1);                     % [m] horizontal step size
dy = Ly/(ny-1);                     % [m] vertical step size
posX = zeros(nx,1);                 % initialization of horizontal position vector
for i=1:nx
    posX(i) = (i-1) * dx;           % creation of horizontal position vector
end
faceX = arithmeticAverage(posX);    % horizontal position at each face
posY = zeros(ny,1);                 % initialization of vertical position vector
for i=1:ny 
    posY(i) = (i-1) * dy;           % creation of vertical position vector
end
faceY = arithmeticAverage(posY);    % vertical position at each face

% Time Parameters
simTime=2*31500000;                 % [s] Simulation time. 1year~31500000s
dt=1e4;                             % [s] Time step size ~ 1e4
tLevel=simTime/dt;                  % [-] Number of time levels
tim=zeros(tLevel,1);                % Initialization of the time vector
for i=1:tLevel                      
    tim(i)=i*dt;                    % The time vector
end

% Faces permeabilities
    % In this section, we evaluate the harmonic means of the intrinsic
    % permeabities in both directions, vertical and horizontal

k = 1e-14 * ones(ny,nx);            % [m^2] intrinsic permeability

hakX = zeros(ny,nx-1);              % initialization of harmonic mean in hor. direction
for a=1:ny
   hakX(a,:) = harmonicAvg(k(a,:)); % creation of harm. mean in hor. direction
end
hakY = zeros(ny-1,nx);            % initialization of harmonic mean in vert. direction
for b=1:nx
   hakY(:,b) = harmonicAvg(k(:,b)); %creation of harmonic mean in vert. direction
end
% See, in the loop from above, that the counter starts from b=2 an goes to
% nx-1, this is because we don't need to take into account the harm. means
% of the first and last columns, 'cause they are BC
hakY_use = hakY;
hakY_use(:,1) = [];
hakY_use(:,end) = [];

% See, in the loop from above that the counter starts and ends normally. We
% are gonna need this in order to plot later on the vertical Darcy velocity


%% Boundary and initial conditions
%Saturation of wetting phase
Sw = ones(ny,nx);                   % [-] Initialization 
Sw(:,end) = 1;                      % [-] Right Boundary ~ Sw=1
Sw(:,1)   = 0;                      % [-] Left Boundary  ~ Sw=0
%Effective saturation 
Swe = effectSat(Sw,Siw);
%Boundary conditions
pn          = 1E+06 * ones(ny,nx);  % [Pa] Initialization pressure non-wetting phase ~ pn=1e-05
pn(:,1)     = 1E+07;                % [Pa] Left boundary pressures
pn(:,end)   = 1E+06;                % [Pa] Right boundary pressures
pL = 1E+07 * ones(ny,1);
pR = 1E+06 * ones(ny,1);

%% Cells to storage information
numP=50;                            % number of printed vectors
SnCell = cell(numP,1);
pnCell = cell(numP,1);
timPlot=zeros(numP,1);

%% Time loop
for w=1:tLevel             % begin of the time loop
   
    if mod(w,(tLevel/numP))==0
        timPlot(w/(tLevel/numP),1)=tim(w);
    end
    
    str=['Simulation time: ' num2str(tim(w)/31500000) ' years'];
    disp(str);
    
  %% Physical parameters that deppends on saturation
  
    %Effective saturation of wettting phase [-]
    Swe = effectSat(Sw,Siw);      % only considering drainage
    
    %Relative permeability of wetting phase [-]
    krw = wetPerm(Swe,alpha);     % via Brooks-Corey
    
    %Relative permeability of non-wetting phase [-]
    krn = nonPerm(Siw,Swe,alpha); % via Brooks-Corey
    
    %Mobility of wetting phase [-]
    mobWet = krw./visWet;
    
    %Mobility of non-wetting phase [-]
    mobNon = krn./visNon;
      
    %Horizontal Upstream mobility of the wetting phase [-]
    upMobWetX = horizUpstreamMobiliy(pn,mobWet);
    
    %Vertical Upstream mobility of the wetting phase [-]
    upMobWetY = verticUpstreamMobiliy(pn,mobWet);
    
    %Horizontal Upstream mobility of the non wetting phase [-]
    upMobNonX = horizUpstreamMobiliy(pn,mobNon);
    
    %Vertical Upstream mobility of the non wetting phase [-]
    upMobNonY = verticUpstreamMobiliy(pn,mobNon);
    
    %Horizontal total upstream mobility [-]
    upMobTotX = upMobWetX + upMobNonX;
    
    %Vertical total upstream mobility [-]
    upMobTotY = upMobWetY + upMobNonY;
    
    %Horizontal upstream wet fractional flow [-]
    upWetFracX = upFracFlow(upMobWetX,upMobNonX);
    
    %Vertical upstream wet fractional flow [-]
    upWetFracY = upFracFlow(upMobWetY,upMobNonY);
    
    % Let's define this variables to simplify the notation (See that the fluxes 
    % are multiplied by the cross sectional area (or length) dy or dx.

    JP = - hakX .* upMobTotX .* (dy/dx);                % this take into account the horizontal term
                                                        % that multiply the pressure
    IP = - hakY .* upMobTotY .* (dx/dy);                  % this take into account the vertical term
                                                        % that multiply the pressure
    IP_use = IP;
    IP_use(:,1) = [];
    IP_use(:,end) = [];
    
    
  %% Solving the linear system

    % The constant matrix:
    % The constant matrix was built applying the discrete equation to every
    % center of each cell. Although the matrix is sparse, due to our BC, we 
    % have been forced to apply this technique in order to generalize the
    % system.

    A = zeros((nx-2)*ny); % initialization of the constant matrix

    % Non-zero elements of the first row. See, that this is a particular case
    % 'cause this first row is affected by the impermeable roof
    row = 1;
    for j=1:inx
        if j==1
            A((row-1)*inx+j,(row-1)*inx+ j) = - JP(row,j) - JP(row,j+1) - IP_use(row,j);    % First column,
            A((row-1)*inx+j,(row-1)*inx+ j+1) = +JP(row,j+1);                           % affected by 
            A((row-1)*inx+j,(row-1)*inx+ j+inx) = +IP_use(row,j);                           % Left BC
        elseif j > 1 && j < inx
            A((row-1)*inx+j,(row-1)*inx+ j-1) = +JP(row,j);                             % 
            A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row,j);     % Internal   
            A((row-1)*inx+j,(row-1)*inx+ j+1) = +JP(row,j+1);                           % Columns
            A((row-1)*inx+j,(row-1)*inx+ j+inx) = +IP_use(row,j);                           %
        elseif j == inx
            A((row-1)*inx+j,(row-1)*inx+ j-1) = +JP(row,j);                             % Last column,
            A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row,j);      % affected by  
            A((row-1)*inx+j,(row-1)*inx+ j+inx) = +IP_use(row,j);                           % Right BC
        end 
    end

    % Internal rows
    for row=2:ny-1  % This loop goes over all the internal rows 
        for j=1:inx % This loop goes over all the columns
            if j == 1
                A((row-1)*inx+j,(row-1)*inx+ j-inx) = +IP_use(row-1,j);                                     % First column,
                A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row,j) - IP_use(row-1,j);    % affected by    
                A((row-1)*inx+j,(row-1)*inx+ j+1) = +JP(row,j+1);                                       % Left              
                A((row-1)*inx+j,(row-1)*inx+ j+inx) = +IP_use(row,j);                                       % Boundary Cond.
            elseif j > 1 && j < inx
                A((row-1)*inx+j,(row-1)*inx+ j-inx) = +IP_use(row-1,j);                                     % 
                A((row-1)*inx+j,(row-1)*inx+ j-1) = +JP(row,j);                                         %
                A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row,j) - IP_use(row-1,j);    % Intern. Column   
                A((row-1)*inx+j,(row-1)*inx+ j+1) = +JP(row,j+1);                                       %
                A((row-1)*inx+j,(row-1)*inx+ j+inx) = +IP_use(row,j);                                       %
            elseif j == inx
                A((row-1)*inx+j,(row-1)*inx+ j-inx) = +IP_use(row-1,j);                                     % Last column,
                A((row-1)*inx+j,(row-1)*inx+ j-1) = +JP(row,j);                                         % affected by
                A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row,j) - IP_use(row-1,j);    % Right    
                A((row-1)*inx+j,(row-1)*inx+ j+inx) = +IP_use(row,j);                                       % Boundary Cond.
            end
        end
    end

    % Non-zero elements of the last row. See, that this is a particular case
    % 'cause this last row is affected by the impermeable bottom
    row = ny;
    for j=1:inx
        if j == 1
            A((row-1)*inx+j,(row-1)*inx+ j-inx) = +IP_use(row-1,j);                         % First column, 
            A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row-1,j);    % affected by
            A((row-1)*inx+j,(row-1)*inx+ j+1) = +JP(row,j+1);                           % Left BC
        elseif j > 1 && j < inx
            A((row-1)*inx+j,(row-1)*inx+ j-inx) = +IP_use(row-1,j);                         % 
            A((row-1)*inx+j,(row-1)*inx+ j-1) = +JP(row,j);                             % Internal 
            A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row-1,j);    % Columns
            A((row-1)*inx+j,(row-1)*inx+ j+1) = +JP(row,j+1);                           % 
        elseif j == inx
            A((row-1)*inx+j,(row-1)*inx+ j-inx) = +IP_use(row-1,j);                         % Last column,
            A((row-1)*inx+j,(row-1)*inx+ j-1) = +JP(row,j);                             % affected by
            A((row-1)*inx+j,(row-1)*inx+ j) = -JP(row,j) - JP(row,j+1) - IP_use(row-1,j);    % Right BC
        end
    end

    % Vector of constants
    b = zeros(inx*ny,1);    % initialization of vector of constants

    % First row
    row = 1; 
    for j=1:inx
        if j == 1
            b((row-1)*inx + j) = -JP(row,j)*pL(row); %first column
        elseif j == inx
            b((row-1)*inx + j) = -JP(row,j+1)*pR(row); %last column
        else
            b((row-1)*inx + j) = 0; %internal columns
        end
    end
    
    % Internal rows
    for row=2:ny-1
        for j=1:inx
            if j == 1
                b((row-1)*inx + j) = -JP(row,j)*pL(row); %first column
            elseif j == inx
                b((row-1)*inx + j) = -JP(row,j+1)*pR(row); %last column
            else
                b((row-1)*inx + j) = 0; %internal columns
            end
        end
    end

    % Last row
    row = ny;

    for j=1:inx
        if j == 1
            b((row-1)*inx + j) = -JP(row,j)*pL(row); %first column
        elseif j == inx
            b((row-1)*inx + j) = -JP(row,j+1)*pR(row); %last column
        else
            b((row-1)*inx + j) = 0; %internal columns
        end
    end


    % Solving the linear system
    x = A\b; % Please MATLAB, solve my Linear System =)

    xMat = zeros(inx,ny); % Let's convert the vector into a matrix
    for row=1:ny
        xMat(:,row) = x((row-1)*inx+1:(row-1)*inx+inx);
    end

    pPlot = zeros(nx,ny); % Let's build the pressure matrix, in order to plot
    for j=1:nx
        if j == 1
            pPlot(j,:) = pL;
        elseif j > 1 && j < nx
            pPlot(j,:) = xMat(j-1,:);
        elseif j == nx
            pPlot(j,:) = pR;
        end
    end
    pPlot = pPlot'; % We have to transpose the pressure matrix
    
     if mod(w,(tLevel/numP))==0
        pnCell{w/(tLevel/numP),1}=pPlot;
    end 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Darcy Velocities

    %Horizontal velocities
    darX = zeros(ny,(nx-1));
    for row=1:ny
        for j=1:nx-1
            darX(row,j) = - (hakX(row,j) .* upMobTotX(row,j)) * ((pPlot(row,j+1)-pPlot(row,j))/dx);
        end
    end

    %Vertical velocities
    darY = zeros(ny-1,nx);
    for row=1:ny-1
        for j=1:nx
            darY(row,j) = - (hakY(row,j) .* upMobTotY(row,j)) * ((pPlot(row,j)-pPlot(row+1,j))/dy);
        end
    end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %% SATURATION EQUATION
    
    %for first row
    i = 1;
    for j=1:inx
        Sw(i,j+1) = (dt/(por*dx*dy))  * (...
                  + upWetFracX(i,j)   * dy * darX(i,j)    ...
                  - upWetFracX(i,j+1) * dy * darX(i,j+1)  ...
                  - upWetFracY(i,j+1) * dx * darY(i,j+1)) ...
                  + Sw(1,j+1);
    end
    
    %internal rows
    for i=2:ny-1
        for j=1:inx
            Sw(i,j+1) = (dt/(por*dx*dy))    * (...
                        + upWetFracX(i,j)   * dy * darX(i,j)   ...
                        - upWetFracX(i,j+1) * dy * darX(i,j+1) ...
                        + upWetFracY(i-1,j+1) * dx * darY(i-1,j+1) ...
                        - upWetFracY(i,j+1)   * dx * darY(i,j+1))  ...
                        + Sw(i,j+1);
        end
    end
    
    %last row
    i = ny;
    for j=1:inx
        Sw(i,j+1) = (dt/(por*dx*dy)) * (...
                  + upWetFracX(i,j)   * dy * darX(i,j)...
                  - upWetFracX(i,j+1) * dy * darX(i,j+1) ...
                  + upWetFracY(i-1,j+1)   * dx * darY(i-1,j+1))...
                  + Sw(i,j+1);
    end
    
    if mod(w,(tLevel/numP))==0
        SnCell{w/(tLevel/numP),1}=1-Sw;
    end
    
end % end of the time loop

%% SATURATION PLOT
figSn = figure;
M=moviein(numP);
view(45,14);
thSn=handle(text('Position',[0,0,-0.5]));
for i=1:numP
    hold on; box on;
    xlabel('Horizontal position [m]','FontSize',11);
    ylabel('Vertical position [m]','FontSize',11);
    zlabel('Saturation of non-wetting phase','FontSize',11);
    colorbar;
    axis square;
    set(gcf,'PaperPosition',[0 0 5 4]);
    set(gcf,'PaperSize',[5 4]);
    thSn.String=sprintf('Time [years]: %1.2f',...
        i*(simTime/(31500000*numP)));
    pause(.001); % let's redraw the axis
    h1 = surf(posX,posY,SnCell{i,1},...
        'EdgeColor','black');
    view(45,14);
    eval(['export_fig -transparent output/sn/img' num2str(i) '.pdf']);
    M(i)=getframe(figSn);
    %delete(h1);
end

%% Pressure plot

figP = figure;
M=moviein(numP);
view(22,12);
thpn=handle(text('Position',[0,0,0]));
for i=1:numP
    hold on; box off;
    xlabel('Horizontal position [m]','FontSize',11);
    ylabel('Vertical position [m]','FontSize',11);
    zlabel('Pressure [Pa]','FontSize',11);
    colorbar;
    axis square;
    set(gcf,'PaperPosition',[0 0 5 4]);
    set(gcf,'PaperSize',[5 4]);
    thpn.String=sprintf('Time [years]: %1.2f',...
        i*(simTime/(31500000*numP)));
    pause(.001); % let's redraw the axis
    h1 = surf(posX,posY,pnCell{i,1},...
        'EdgeColor','black');
    %eval(['export_fig -transparent output/pn/img' num2str(i) '.pdf']);
    M(i)=getframe(figP);
    delete(h1);
end






