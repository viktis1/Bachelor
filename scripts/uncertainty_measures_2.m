%% Calculating uncertainty as a function of PRF
clc; clearvars; close all

% Defining the PRF spectrum
PRF = linspace(10e3, 70e3, 1000); % [Hz]

% Parameters
f_m = 50; % [Hz] rotational frequency
R = 0.36/2; % [m]
N_FFT = 64; % Amount of points to be included in our STFT
omega_m = 2*pi*f_m; % [rad/Hz] angular frequency
c = 3e8; % [m/s]
f_c = 9.4e9; % [Hz]
lambda_c = c/f_c; % [m]


f_D_migration_max = sqrt(2)*R*omega_m^2*N_FFT./(PRF*lambda_c);
f_D_time_change = 2/lambda_c *R*omega_m *abs(cos(pi/4) - cos(pi/4 - omega_m*N_FFT./PRF)); %[Hz]
f_D_unambiguous = PRF/2; %[Hz]
f_D_res = 1./(N_FFT./PRF); %[Hz]



PRF_label = (10:5:90)*1e3;
figure()
hold on
plot(PRF*1e-3, f_D_time_change*1e-3, 'DisplayName', 'Doppler Migration')
% plot(PRF*1e-3, f_D_migration_max*1e-3, 'DisplayName', 'Doppler Migration Jørgen')
plot(PRF*1e-3, f_D_res*1e-3, 'DisplayName', 'Doppler resolution')
xlabel('PRF [kHz]')
ylabel('Doppler Uncertainty [kHz]')
grid()
% xticks(PRF_label*1e-3)
% xticklabels({round(omega_m*N_FFT./PRF_label*180/pi, 1)})
% xlabel('\Delta\phi [deg]')
legend()



