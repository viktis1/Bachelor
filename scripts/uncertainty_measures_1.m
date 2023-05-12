%% Calculating PRF
clc; clearvars; close all

% Parameters we can change
angle_diff = 15*pi/180 ; % [radians] The maximum angular difference in STFT
N_w = 32; % The minimum amount of points we will allow in STFT

% Defining frequency and radius vectors to be used for plotting
f_m = linspace(50, 150, 1000); % [Hz] propeller frequency
r_L = linspace(0.1, 0.3, 3); % [m] propeller radius

% locked parameters
c = 3e8; % [m/s]
f_c = 9.4e9; % [Hz]
omega_m = 2*pi*f_m; % [Hz] angular frequency
lambda_c = c/f_c; % [m]
T_w = angle_diff./omega_m; % [s]

% Extras
color_ramp = ["#FF1010", "#8C145A", "#1919A4"];


figure()
hold on
% Finding a PRF constraint with respect to keeping at least N_w points in
% our delta_theta interval
f_PRF_2 = N_w./T_w*1e-3; % [kHz]
plot(f_m, f_PRF_2, 'DisplayName', 'STFT constraint', 'Color', "#00FF00", 'LineWidth',1.5)

for i=1:length(r_L)
    % Finding a PRF constraint with respect to containing the entire
    % Doppler spectrum
    f_D_max = 2*r_L(i)*omega_m/lambda_c; % [Hz] 
    f_PRF_1 = 2*f_D_max*1e-3; % [kHz] Nyquist theorem
    
    plot(f_m, f_PRF_1, 'DisplayName', ['Doppler unambiguous r = ', num2str(r_L(i)*100), 'cm'], 'Color', color_ramp(i), 'LineWidth',1.5)
end
legend()
title('Constraints on PRF')
grid()
ylabel('PRF [kHz]')
xlabel('Rotor Frequency [Hz]')



%% Doppler Migration


figure()
hold on
f_D_res = 1./T_w*1e-3; % [kHz]
plot(f_m, f_D_res, 'DisplayName', 'Doppler res', 'LineWidth',1.5)
% plot(T_w*1e6, f_D_res, 'DisplayName', 'Doppler res')


for i=1:3
    delta_f_D_time = 2/lambda_c *r_L(i)*2*pi*f_m *abs(cos(pi/4) - cos(pi/4 - angle_diff))*1e-3; % [kHz]
%     plot(T_w*1e6, delta_f_D_time, 'DisplayName', ['radius ', num2str(r_L(i)*100), ' cm'])
    plot(f_m, delta_f_D_time, 'DisplayName', ['Doppler change r = ', num2str(r_L(i)*100), 'cm'], 'LineWidth',1.5)
end

% xlabel('T_w [micro second]')
xlabel('f_m [Hz]')
ylabel('Doppler uncertainty [kHz]')
legend()
grid()


%% Rotor arm
f_rotor = 2000/60; % [Hz] rms*60sec/min
T_w_rotor = angle_diff/(2*pi*f_rotor); % [s]
f_PRF = N_w/T_w_rotor*1e-3; %[kHz]

fprintf("The rotor will need a PRF of %0.1f kHz, the time window will be %0.0f micro seconds and the \n" + ...
    "rotor has a period frequency of %0.0f Hz \n\n", f_PRF, T_w_rotor*1e6, f_rotor);

%% Estimating the error of taylor approximating sin to 1st order
% clc; clearvars; close all  
% [phase, delta_phase] = meshgrid(linspace(0, pi/4, 250), linspace(0, 15*pi/180, 250));
% approx = sin(phase).*delta_phase/(2*pi);
% excact = cos(phase + delta_phase) - cos(phase);
% dif = excact - approx;
% 
% scatter(phase(:), delta_phase(:), [], phase(:), 'filled')
% xlabel(['\phi [', char(176), ']'])
% ylabel(['\Delta \phi [', char(176), ']'])
% xlim([0, pi/4])
% ylim([0, pi/2])
% xticks((0:5:45)*pi/180)
% xticklabels({0:5:45})
% yticks((0:10:90)*pi/180)
% yticklabels({0:10:90})
% colorbar()
% % plot(excact)



