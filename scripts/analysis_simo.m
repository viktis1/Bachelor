clc; clearvars; close all


% Load constants
c = 3e8; % [m/s] speed of light
f_c = 9.4e9; % [Hz]
lambda_c = c/f_c; % [m]

% Define the PRF for the SIMO waveform
f_PRF = 62500;

% Loading the data for the different measurements
simo = load("../måling/RDC_MF_Propel A - Fast Speed_Wave 02 - SIMO.mat") % unprocessed data
simoTest = load("../SIMO_data/SIMO_data_Prop-A-Fast.mat")
% simo.SYS % The parameters we gave to generate the wave.

%% Trying to find x_signal
clc;
simoData = simo.RDC_MF; % unprocessed data
range_signal = permute(sum(simoData, 2), [1, 3, 2]); % Signalet er nu SISO
sum(sum(range_signal - simoTest.cplxData)) % =0

range_signal_size = abs(range_signal);

rotor_signal = sum(range_signal([9, 10, 11, 12], :));
rotor_signal = rotor_signal./max(abs(rotor_signal));

sum(rotor_signal - simoTest.x_signal) %=0

%% mapping slow- and fast time
fig = figure();
hold on
imagesc(simoTest.slowTimeBins*1e3, simoTest.rangeBins, range_signal_size)
xlim([0, max(simoTest.slowTimeBins)])
ylim([0, max(simoTest.rangeBins)])
xlabel('slow time [s]')
ylabel('Range [m]')
hold off
saveas(fig, '../figures/PropelAFast_slowFastTimeMap.png')

%% mapping velocity power spectrum
% Isolate the signal for the range gates
gate_signal = simoTest.cplxData(simoTest.idxTarget, :);

% create the spectrum 
spectrum = fft(gate_signal.');
% shift the spectrum so it is centered at f=0
spectrum_shifted = fftshift(spectrum);
% Find the power spectrum in dB
spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));
% Normalize the spectrum 
spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB);
% Define the frequency axis for the new spectrum
fBins = linspace(-f_PRF/2, f_PRF/2,length(simoTest.slowTimeBins));
% a Doppler measurement is given as f = 2v/lambda. To find velocity instead,
vBins = lambda_c*fBins/2;

% Load legend names for plotting 
range_labels = repmat("range: ",4,1) + simoTest.rangeBins(simoTest.idxTarget).'; 

% Finding an estimate of the maximal radial velocity with rotor frequency:
% 50 Hz and the wing radius as 18 cm
v_max_est = 0.18*2*pi*26 % [m/s]


fig = figure();
hold on
for i = 1:4
    plot(vBins, spectrum_shifted_dB_norm(:, i), 'DisplayName', range_labels(i))
end
xline([-v_max_est, v_max_est], 'r--', 'DisplayName','maximum radial velocity', 'LineWidth',1.5)
xlabel('Velocity [m/s]')
ylabel('Normalized Power Spectrum [dB]')
legend()
legend(repmat("range: ",4,1) + simoTest.rangeBins(simoTest.idxTarget).')
saveas(fig, '../figures/PropelAFast_signalVelocityPower.png')


fig = figure();
hold on
for i = 1:4
    plot(vBins, spectrum_shifted_dB_norm(:, i), 'DisplayName', range_labels(i))
end
xline([-v_max_est, v_max_est], 'r--', 'DisplayName','maximum radial velocity', 'LineWidth',1.5)
xlabel('Velocity [m/s]')
ylabel('Normalized Power Spectrum [dB]')
legend()
xlim([-100, 100])
hold off
saveas(fig, '../figures/PropelAFast_signalVelocityPowerZoom.png')

%% Finding time parameter (Dwell time) for STFT - MANUALLY
fm = 50; % [Hz]
r = 0.36/2; % [m]
t_PRI = 1/f_PRF; %[Hz]
TD_list = (32:(1/fm)/t_PRI)*t_PRI; %[s]

delta_f_time = abs(2/lambda_c * r*2*pi*fm*(cos(pi/4) - cos(pi/4 - 2*pi*fm*TD_list))); %[Hz]
f_res = 1./TD_list; %[Hz]

TD_approx = 70/(360*fm); % [s]
TD_guess = round(TD_approx*f_PRF)*t_PRI; % [s] THIS HAS TO BE A MULTIPLE OF t_PRI
f_uncertainty = abs(2/lambda_c * r*2*pi*fm*(cos(pi/4) - cos(pi/4 - 2*pi*fm*TD_guess))) + 1/TD_guess;
fprintf("Our dwell time guess is %0.0f ms and the Doppler resolution from " + ...
    "this dwell time is %0.2f kHz\n", TD_guess*1e3, 1/TD_guess*1e-3);

fig = figure();
hold on
plot(TD_list*1e3, f_res*1e-3, '.-', 'DisplayName', 'Doppler Resolution')
plot(TD_list*1e3, delta_f_time*1e-3, '.-', 'DisplayName', 'Doppler Migration')
xline(1/fm*1e3, 'k-.', 'DisplayName', 'Rotation Period (360^o)', 'LineWidth',1.5)
xline(1/fm*1e3/4, 'r-.', 'DisplayName', '1/4 Rotation Period (90^o)', 'LineWidth',1.5)
xline(23/(360*fm)*1e3, 'DisplayName', 'Dwell Time Guess', 'LineWidth',1.5)
xlabel('Dwell Time [ms]')
ylabel('Frequency Uncertainty [kHz]')
title_label = sprintf('f_{PRF} = %0.1f kHz, f_{rot} = %i Hz, r = %0.2f m', f_PRF*1e-3, fm, r);
title(title_label)
legend()
grid()
hold off
saveas(fig, '../figures/PropelAFast_DwellTime.png')



%% Finding STFT of rotor signal - rect window; automated

% To do the STFT of the signal, a rectangular window will be used. The
% following parameters will be necessary:
%
% tau - the slow time point we're trying to find the doppler shift of.
% TD - Dwell time. +- T_D/2 on either side of tau
% rotor_signal - the 1D signal we are trying to analyze.
% ST - the slow time corresponding to each point in x_signal
TD = TD_guess - 1e-16;
rotor_signal = simoTest.x_signal;
ST = simoTest.slowTimeBins;

spacing = TD/2; % Define the spacing between elements in tau_list
tau_list = (TD/2:spacing:max(ST)-TD/2);

% Define the slowtime index for timestamps lying in tau+-TD/2
ST_index = (ST <= tau_list.' + TD/2) & (ST >= tau_list.' - TD/2);

% create the frequency axis
fBins = (-f_PRF/2: 1/TD :f_PRF/2);

% Verify that the index is good and if it isn't print an error
if sum(sum(ST_index, 2) ~= median(sum(ST_index, 2))) ~= 0
    fprintf(['\n\n' ...
        'Manual Error - Short Time: Something Went Wrong in section: \n ' ...
        '%%%% Finding STFT of Rotor Signal  - automated \n'])
    return
end


matrix = zeros(round(f_PRF*TD_guess), length(tau_list));

% Create a spectrum for all time points in tau_list
for i=1:length(tau_list)
    tau = tau_list(i);
    ST_index = (ST<=tau+TD/2) & (ST>=tau-TD/2);

    % Verify that the index is good and if it isn't print an error
    if (max(ST(ST_index))-min(ST(ST_index))) > TD
        fprintf(['Manual Error: Something Went Wrong in section: \n ' ...
            '%%%% Finding STFT of Rotor Signal - automated \n'])
        return
    end

    % Create the spectrum and then shift it.
    % Change the measurement unit to dB and then normalize the spectrum
    spectrum = fft(rotor_signal(ST_index));
    spectrum_shifted = fftshift(spectrum);
    spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));
    spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB);
    
    matrix(:, i) = spectrum_shifted_dB_norm;
end


fig = figure();
hold on
imagesc(tau_list, fBins*1e-3, matrix)
xlim([0, max(tau_list)])
ylim([min(fBins*1e-3), max(fBins*1e-3)])
xlabel('slow time [s]')
ylabel('frequency [kHz]')
c = colorbar();
ylabel(c, 'power [dB]')
hold off
saveas(fig, '../figures/PropelAFast_signalSTFT_rectWindow.png')


%% Finding STFT of rotor signal - Blackman window; automated

% To do the STFT of the signal, a rectangular window will be used. The
% following parameters will be necessary:
%
% tau - the slow time point we're trying to find the doppler shift of.
% TD - Dwell time. +- T_D/2 on either side of tau
% rotor_signal - the 1D signal we are trying to analyze.
% ST - the slow time corresponding to each point in x_signal
TD = TD_guess - 1e-16;
n_TD = round(f_PRF*TD_guess);
rotor_signal = simoTest.x_signal;
ST = simoTest.slowTimeBins;

spacing = TD/2; % Define the spacing between elements in tau_list
tau_list = (TD/2:spacing:max(ST)-TD/2);

% Define the slowtime index for timestamps lying in tau+-TD/2
ST_index = (ST <= tau_list.' + TD/2) & (ST >= tau_list.' - TD/2);

% create the frequency axis
fBins = (-f_PRF/2: 1/TD :f_PRF/2);

% Verify that the index is good and if it isn't print an error
if sum(sum(ST_index, 2) ~= median(sum(ST_index, 2))) ~= 0
    fprintf(['\n\n' ...
        'Manual Error - Short Time: Something Went Wrong in section: \n ' ...
        '%%%% Finding STFT of Rotor Signal  - automated \n'])
    return
end


matrix = zeros(n_TD, length(tau_list));

% Create a spectrum for all time points in tau_list
for i=1:length(tau_list)
    tau = tau_list(i);
    ST_index = (ST<=tau+TD/2) & (ST>=tau-TD/2);

    % Verify that the index is good and if it isn't print an error
    if (max(ST(ST_index))-min(ST(ST_index))) > TD
        fprintf(['Manual Error: Something Went Wrong in section: \n ' ...
            '%%%% Finding STFT of Rotor Signal - automated \n'])
        return
    end

    % Create the new rotor signal with the appropriate window
    rotor_signal_blackman = rotor_signal(ST_index).*blackman(n_TD).';
    % Create the spectrum and then shift it.
    % Change the measurement unit to dB and then normalize the spectrum
    spectrum = fft(rotor_signal_blackman);
    spectrum_shifted = fftshift(spectrum);
    spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));
    spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB);
    
    matrix(:, i) = spectrum_shifted_dB_norm;
end


fig = figure();
hold on
imagesc(tau_list, fBins*1e-3, matrix)
xlim([0, max(tau_list)])
ylim([min(fBins*1e-3), max(fBins*1e-3)])
xlabel('slow time [s]')
ylabel('frequency [kHz]')
c = colorbar();
ylabel(c, 'power [dB]')
hold off
saveas(fig, '../figures/PropelAFast_signalSTFT_blackmanWindow.png')






%% Finding antenna phase

simoData = permute(simo.RDC_MF, [3,1,2]);
simoData_angle = angle(simoData)*180/pi; % [deg]
range_index_list = [2, 3, 4, 5, 6];
range_index_list = [44, 45, 46];



% antenna phase
% Create figure
fig = figure();
t = tiledlayout(1, length(range_index_list));
t.TileSpacing ='compact';


for range_index = range_index_list
nexttile(t)
hold on
for i =1:7
    % Find the phase difference between the 2 gates
%     angleDif = simoData_angle(:, range_index, i) - simoData_angle(:, range_index, i+1);
    angleDif = angle(simoData(:, range_index, i)./simoData(:, range_index, i+1))*180/pi;
    
    % Make sure that the phase difference lies in the interval[-180, 180]
    angleDif(angleDif < -180) = angleDif(angleDif < -180) + 360;
    angleDif(angleDif > 180) = angleDif(angleDif > 180) - 360;

    % Plot the results
    legend_name = join(['Rx', num2str(i), '-Rx', num2str(i+1)], '');
    line(i) = plot(simoTest.slowTimeBins, angleDif, '.-', 'DisplayName',legend_name, ...
        'MarkerSize',10);
    ylim([-180, 180])
    xlim([0, max(simoTest.slowTimeBins)])
    title(join(['Range: ', num2str(round(simoTest.rangeBins(range_index)-2.905,1)), 'm'], ''))
    grid()
end
end
% Construct a Legend 
lg = legend(line); 
lg.Layout.Tile = 'East';
xlabel(t, 'Slow Time [s]')
ylabel(t, '\Delta \theta [Deg]')
title(t, 'Relative Spatial Phase Differences')
saveas(fig, '../figures/spatial_phaseDif.png')


%% Antenna Phase 2.0

simoData = permute(simo.RDC_MF, [3,1,2]);
simoData_angle = angle(simoData)*180/pi; % [deg]
time_stamp_index = [1e4, 2e4, 3e4];
time_stamp_index = [1e4];

% Create figure
fig = figure();
t = tiledlayout(1, length(time_stamp_index));
t.TileSpacing ='compact';

% Load arrays to be used for plotting
x_array = ["Rx1-Rx2", "Rx2-Rx3", "Rx3-Rx4", "Rx4-Rx5", "Rx5-Rx6", "Rx6-Rx7", "Rx7-Rx8"];
ranges = simoTest.rangeBins - 2.905;

matrix = zeros(200, 7, length(time_stamp_index), 2);
for time_index = time_stamp_index
nexttile(t)
    for i = 1:7
        % Find the phase difference between the 2 gates
        angleDif = simoData_angle(time_index, :, i) - simoData_angle(time_index, :, i+1);
        
        % Make sure that the phase difference lies in the interval[-180, 180]
        angleDif(angleDif < -180) = angleDif(angleDif < -180) + 360;
        angleDif(angleDif > 180) = angleDif(angleDif > 180) - 360;

        % Load the absolute size 
        meanSize = mean([abs(simoData(time_index, :, i)); abs(simoData(time_index, :, i))], 1);
    
        % Load the results into a matrix
        matrix(:, i, time_index, 1) = angleDif;
        matrix(:, i, time_index, 2) = meanSize;
    end
startpoint = length(ranges) - length(ranges(ranges > 0)) + 1
norm_factor_size = max(matrix(startpoint:end, :, time_index, 2), [], "all")
im = imagesc('xData', 1:7, ...
    'yData', ranges, ...
    'CData', matrix(:, :, time_index, 1), ...
    'AlphaData', matrix(:, :, time_index, 2)/norm_factor_size)
xticks(1:7)
xticklabels(x_array)
ylabel('Range [m]')
ylim([0, 30])
colorbar()
xlim([0.5,7.5])
end


% imagesc(simoTest.slowTimeBins*1e3, simoTest.rangeBins, range_signal_size)
% xlim([0, max(simoTest.slowTimeBins)])
% ylim([0, max(simoTest.rangeBins)])
% xlabel('slow time [s]')
% ylabel('Range [m]')


