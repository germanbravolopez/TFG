% Li-ion battery model based on the SPM, that uses the "pdepe" function to 
% integrate the equation of the lithium concentration in the solid particle.
clear all
close all
clf
% --------------------------------------------------------------
% --------------------------------------------------------------
% Simulation parameters
% --------------------------------------------------------------
i_salida = -6.019;       % [A] Cell's output current
r = linspace(0,1e-4,60);  % [cm] Radius of the electrode
t = linspace(0,3780,800); % [s] Simulation time
sincorte = 1;             % Poner 1 si no se desea corte

% --------------------------------------------------------------
% FreedomCar table's parameters
% --------------------------------------------------------------
tic
% Design specifications (geometry and volume fractions)
delta_p = 36.4e-4; delta_n = 50e-4;  % [cm] Thickness
L_p = 36.4e-4; L_n = 50e-4;          % [cm] Thickness
R_p = 1e-4;                          % [cm] Particle radius
epsilon_sp = 0.5; epsilon_sn = 0.58; % Active material volume fraction
A = 10452;                           % [cm^2] Electrode plate area

% Solid and electrolyte phase Li-ion concentration (0% and 100% SOC)
global beta_n100 beta_n0 beta_p100 beta_p0 c_smaxp c_smaxn 
c_smaxp = 23.9e-3; c_smaxn = 16.1e-3; % [mol*cm^-3] Maximum solid phase concentration
beta_n100 = 0.676; beta_n0 = 0.126;   % Negative electrode stoichiometry 
beta_p100 = 0.442; beta_p0 = 0.936;   % Positive electrode stoichiometry
c_e = 1.2e-3; % [mol*cm^-3] Initial electrolyte phase concentration

% Kinetic and transport properties
i_0p = 2.6e-3; i_0n = 3.6e-3; % [A*cm^-2] Exchange current density
D_sp = 3.7e-12; D_sn = 2e-12; % [cm^2*s^-1] Solid phase Li diffusion coeficient
D_e = 2.6e-6; % [cm^2*s^-1] Electrolyte phase Li-ion diffusion coeficient

R_collector = 1.9e-3; % [Ohms] Current collector contact resistant
R_SEI = 0e-3; % [Ohm*cm^-1] Solid-electrolyte interphase layer film resistance
R_SEI =R_SEI*A;
% Constants
F = 96478; % [C*mol^-1] Faraday's constant
R = 8.314; % [J*mol^-1] Universal gas constant 
T = 298;   % [K] Temperature
r_eff = 1; % [mol*cm^-2*s^-1*(mol*cm^-1*s)^-1.5] Reaction rate constant

% --------------------------------------------------------------
% Model equations
% --------------------------------------------------------------

% Equation of the specific area
    a_p = 3*epsilon_sp/R_p;
    a_n = 3*epsilon_sn/R_p;

% Molar flux equation
    global I
    I = i_salida/A; % [A*cm^-2] Current per area unit
    j_np = -(I)./(F*a_p*L_p);
    j_nn = (I)./(F*a_n*L_n);

% Li-ion concentration in the solid particles
% Initial execution. Find the cut time
    global t_corte
    c_sp_prom = concentration_p_inicial(r,t);
    I = i_salida/A;
    c_sn_prom = concentration_n_inicial(r,t);
    I = i_salida/A;
    
    tmin_n = find(c_sn_prom == min(c_sn_prom));
    tmin_p = find(c_sp_prom == max(c_sp_prom));
    t_corte = t(min(tmin_n,tmin_p));
    if sincorte == 1
        t_corte = 3800;
    end
% Second execution
    c_sp = concentration_p(r,t);
    I = i_salida/A;
    c_sn = concentration_n(r,t);
    I = i_salida/A;

% Surface concentration of Li-ion in the solid particle
    c_ssp = c_sp(:,end);
    c_ssn = c_sn(:,end);
    
% Stoichiometry for the potential
%     beta_p = c_ssp./c_smaxp;
%     beta_n = c_ssn./c_smaxn;
    beta_p = 0:0.001:1;
    beta_n = 0:0.001:1;
% Open circuit potential
    U_p = 85.681.*beta_p.^6-357.7.*beta_p.^5+613.89.*beta_p.^4-555.65.*beta_p.^3+281.06.*beta_p.^2-76.648.*beta_p-0.30987.*exp(5.657.*beta_p.^115)+13.1983;
    U_n = 8.00229+5.0647.*beta_n-12.578.*beta_n.^(1/2)-8.6322e-4.*beta_n.^(-1)+2.1765e-5.*beta_n.^(3/2)-0.46016.*exp(15.*(0.06-beta_n))-0.55364.*exp(-2.4326.*(beta_n-0.92));
close all
figure(1)
plot(beta_p,U_p)
figure(2)
plot(beta_n,U_n)
% Potential equations
    theta_s0p = (2.*R.*T./F).*asinh(-I./(2.*a_p.*L_p.*r_eff.*sqrt(c_e.*c_ssp.*(c_smaxp-c_ssp)))) + U_p - (R_SEI.*I)./(a_p.*L_p);
    theta_s0n = (2.*R.*T./F).*asinh(I./(2.*a_n.*L_n.*r_eff.*sqrt(c_e.*c_ssn.*(c_smaxn-c_ssn)))) + U_n + (R_SEI.*I)./(a_n.*L_n);
    
% Output voltage
    V = theta_s0p - theta_s0n;

    figure(6)
    plot(t,V)
    title('Tensi�n de salida de la bater�a')
    xlabel('Tiempo, t [s]')
    ylabel('Tensi�n, V [V]')

% --------------------------------------------------------------
% Calculate C-rate
    Q_p = A*F*L_p*epsilon_sp*c_smaxp*(beta_p100-beta_p0)/3600;
    Q_n = A*F*L_n*epsilon_sn*c_smaxn*(beta_n100-beta_n0)/3600;
    Q_batt = abs(min(Q_p,Q_n));          % [Ah] Battery capacity
    C_rate = abs(i_salida)/Q_batt        % Rate of discharge
    
    SOC = (c_sp_prom/c_smaxp-beta_p0)/(beta_p100-beta_p0);

figure(7)
plot(t,SOC*100)
title('Estado de carga')
xlabel('Tiempo, t [s]')
ylabel('SOC(%)')

figure(8)
plot(SOC*100,V)%,'r',SOC*100,U_p,'b',SOC*100,theta_s0p,'k')
title('Tensi�n de salida')
xlabel('SOC(%)')
ylabel('Tensi�n, [V]')
% legend('Tensi�n de salida','OCV^+','theta^+')
   
tSim = toc % [s] Time the program takes to end

savdir = 'C:\Users\Usuario\Desktop\German\UNIVERSIDAD\4o\2o_cuatrimestre\TFG\Modelos_batt\BATT_MODEL';
save(fullfile(savdir,'V_spm.txt'),'V','-ascii');
save(fullfile(savdir,'t_spm.txt'),'t','-ascii');