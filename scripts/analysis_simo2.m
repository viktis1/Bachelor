clc;clearvars; %close all

%% Run all the functions for spectrogram generation
cutoff = -30;
subsampling = 1;

analysis_simo_func('blackman-harris', 'SIMO_data_Prop-A-Fast.mat', cutoff, "auto", subsampling)
% analysis_simo_func('blackman-harris', 'SIMO_data_Prop-A-Med.mat', cutoff, "auto", subsampling)
% analysis_simo_func('blackman-harris', 'SIMO_data_Prop-A-Slow.mat', cutoff, "auto", subsampling) 
analysis_simo_func('blackman-harris', 'SIMO_data_Prop-B-Fast.mat', cutoff, "auto", subsampling)
% analysis_simo_func('blackman-harris', 'SIMO_data_Prop-C.mat', cutoff, "auto", subsampling)
% analysis_simo_func('blackman-harris', 'SIMO_data_Reference.mat', cutoff, "auto", subsampling)

%% Run all function for welsh power sampling
power_sampling_groups = 1% 3 is the golden number for all measurements, when fully sampled

welsh_power_sampling('SIMO_data_Prop-A-Fast.mat', power_sampling_groups, 'blackman-harris')
welsh_power_sampling('SIMO_data_Prop-A-Med.mat', power_sampling_groups, 'blackman-harris')
welsh_power_sampling('SIMO_data_Prop-A-Slow.mat', power_sampling_groups, 'blackman-harris') 
welsh_power_sampling('SIMO_data_Prop-B-Fast.mat', power_sampling_groups, 'blackman-harris')
welsh_power_sampling('SIMO_data_Prop-C.mat', power_sampling_groups, 'blackman-harris')
welsh_power_sampling('SIMO_data_Reference.mat', power_sampling_groups, 'blackman-harris')

%% Run all function for rotor periods
saveMode = true

rotor_period_detection('SIMO_data_Prop-A-Fast.mat', saveMode)
rotor_period_detection('SIMO_data_Prop-A-Med.mat', saveMode)
rotor_period_detection('SIMO_data_Prop-A-Slow.mat', saveMode) 
rotor_period_detection('SIMO_data_Prop-B-Fast.mat', saveMode)
rotor_period_detection('SIMO_data_Prop-C.mat', saveMode) 
rotor_period_detection('SIMO_data_Reference.mat', saveMode)


%% window analysis

% Create the spectrum of the three windows to compare the mainlobe
% widening:
n_TD = 2^11;
t = linspace(-0.15, pi+0.15, n_TD);
signal = square(t).';

figure()
plot(t, signal)
xlim([min(t), max(t)])

wBlackman = blackman(n_TD);
wBlackmanharris = blackmanharris(n_TD);
wRect = ones(n_TD, 1);
wHamming = hamming(n_TD);
windows = [wRect, wHamming, wBlackman, wBlackmanharris];

xAxis = (-n_TD/2:n_TD/2-1)/n_TD*100; % [%]
for i = 1:4
    w = windows(:, i);
    spectrum = fft(signal.*w);
    spectrum_shifted = fftshift(spectrum);
    spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));
    spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB);

    figure()
    plot(xAxis, spectrum_shifted_dB_norm)
    xlim([-10, 10])
    ylim([-40, 0])
end

%% cluster analysis - NOT WORKING WELL
simoTest = load("../SIMO_data/SIMO_data_Prop-A-Fast.mat");
% Define spectrum
spectrum_shifted_dB = 10*log10(abs(fftshift(fft(simoTest.x_signal)))); %find the spectrum centered at f=0 in dB
spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB); % normalize the spectrum
% Define frequency bins
f_PRF = 62.5e3;
fBins = linspace(-f_PRF/2, f_PRF/2,length(simoTest.slowTimeBins));
% Create a matrix for k mean clustering algorithm
X(:, 1) = abs(fBins);
X(:, 2) = abs(fftshift(fft(simoTest.x_signal)));
n_cluster = 2;
idx = kmeans(X, n_cluster, 'distance', 'sqeuclidean');
figure()
hold on
for i=1:n_cluster
    index = (idx==i);
    plot(fBins(index), spectrum_shifted_dB_norm(index))
end

%% Thresholding with -30 dB
simoTest = load("../SIMO_data/SIMO_data_Prop-A-Fast.mat");
% Define spectrum
spectrum_shifted_dB = 10*log10(abs(fftshift(fft(simoTest.x_signal)))); %find the spectrum centered at f=0 in dB
spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB); % normalize the spectrum
% Define frequency bins
f_PRF = 62.5e3;
fBins = linspace(-f_PRF/2, f_PRF/2,length(simoTest.slowTimeBins));


% make a mask that removes all measurements below -30 dB
cutoff = -30;
index = (spectrum_shifted_dB_norm > -30);
min(rmoutliers(fBins(index)))

%% Finding Radar Delay

% Load where the corner reflectors were placed
dihedral_placement = 8.08; %[m]
trihedral_placement = 23.90; %[m]

% from Plot: 
radar_delay_dihedral = mean([10.95, 10.6, 10.5, 10.5] - dihedral_placement) % [m]
radar_delay_trihedral = 26.805-trihedral_placement % = 2.905 [m]
radar_delay = radar_delay_trihedral % [m]

simoTest = load("../SIMO_data/SIMO_data_Prop-A-Fast.mat"); % Just for ranges


% Find all matlab files in the SIMO_data directory folder
myFiles = dir(fullfile("../SIMO_data/",'*.mat'));


% Initialize figure for plotting the different range intensities
fig = figure();
t = tiledlayout(1,1,'Padding','tight');
t.Units = 'inches';
t.OuterPosition = [0.25 0.25 5.2 2.5];
nexttile()
hold on

n_plot = 1000; % How many points i will interpolate to with fourier transform
rangeAxis = linspace(1, max(simoTest.rangeBins), n_plot);
fastTimeAxis = 2*rangeAxis/3e8; % [s]

% Iterate through all the files
for k = 1:length(myFiles)
    fileName = myFiles(k).name;
    legendName = extractBefore(extractAfter(fileName, 10), length(extractAfter(fileName, 10))-3); % Load the central part of word
    simoTest = load("../SIMO_data/"+fileName);
    
    % Fourier Interpolation
    range_interp = interpft(simoTest.cplxData, n_plot, 1);

    plot(fastTimeAxis*1e6, abs(mean(range_interp, 2)).', 'DisplayName',legendName, 'LineWidth',1.5)        
end

% Plot the placement of the reflectors to correct for a radar delay
xline(dihedral_placement*2/3e8*1e6, 'r--', 'LineWidth',1.5, 'DisplayName','Dihedral')
xline(trihedral_placement*2/3e8*1e6, 'k--', 'LineWidth',1.5, 'DisplayName','Trihedral')
xlim([0, 0.2]) % zoom in on the area we are interested in
% xticks(round([0, 5, dihedral_placement+radar_delay_dihedral, ...
%     15, 20, 25, trihedral_placement+radar_delay_trihedral, 30],1))
xlabel('Fast Time [\mus]') 
title('Finding Radar Delay')
legend('Location','north')
yticks([])
ylabel('Intensity')
hold off
saveas(t, "../figures/radar_delay.png")
saveas(fig, "../figures/radar_delay.eps")


%% Find parameter for estimating dwell time

myFiles = [ "SIMO_data_Prop-B-Fast.mat", ...
            "SIMO_data_Prop-A-Fast.mat", ...
            "SIMO_data_Prop-A-Med.mat", ...
            "SIMO_data_Prop-A-Slow.mat"];
k = 9:18;
parameter_plot('blackman', myFiles, -30, k)





%% Antenna phase through range

simoTest = load("../SIMO_data/SIMO_data_Prop-A-Fast.mat");
% Find all matlab files in the SIMO_data directory folder
myFiles = dir(fullfile("../måling/rådata/", '*.mat'));
for k = 1:length(myFiles)
    fileName = myFiles(k).name;
    simo = load(join(["../måling/rådata/",fileName],''));
    
    % Wave_label 
    fname_split = split(fileName, '.')
    if strcmp(fname_split(1), 'RDC_MF_Propel A - Fast Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Rotor 24 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel A - Med Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Rotor 13 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel A - Slow Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Rotor 9 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel B - Fast Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Al. Rotor 24 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel C_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Noisy Rotor';
    elseif strcmp(fname_split(1), 'RDC_MF_Reference_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Reference';
    end
    % Load the data
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
    
    % Predefine a matrix for for-loop
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
    
    % Define the plot and settings for it
    startpoint = length(ranges) - length(ranges(ranges > 0)) + 1;
    norm_factor_size = max(matrix(startpoint:end, :, time_index, 2), [], "all");
    im = imagesc('xData', 1:7, ...
        'yData', ranges, ...
        'CData', matrix(:, :, time_index, 1), ...
        'AlphaData', matrix(:, :, time_index, 2)/norm_factor_size);
    xticks(1:7)
    xticklabels(x_array)
    ylabel('Range [m]')
    ylim([0, 30])
    colorbar()
    xlim([0.5,7.5])
    title(save_name)
    subtitle('Spatial Phase Differences on objects')
    saveas(fig, join(["../figures/spatial_phaseDif_importantRanges_", save_name, ".png"],''))

    end
    
end




%% Finding antenna phase through slow time


simoTest = load("../SIMO_data/SIMO_data_Prop-A-Fast.mat");
% Find all matlab files in the SIMO_data directory folder
myFiles = dir(fullfile("../måling/rådata/", '*.mat'));
for k = 1:length(myFiles)
    fileName = myFiles(k).name;
    simo = load(join(["../måling/rådata/",fileName],''));
    
    % Wave_label 
    fname_split = split(fileName, '.')
    if strcmp(fname_split(1), 'RDC_MF_Propel A - Fast Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Rotor 24 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel A - Med Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Rotor 13 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel A - Slow Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Rotor 9 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel B - Fast Speed_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Al. Rotor 24 Hz';
    elseif strcmp(fname_split(1), 'RDC_MF_Propel C_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Noisy Rotor';
    elseif strcmp(fname_split(1), 'RDC_MF_Reference_Wave 02 - SIMO_SIMO_burst001')
        save_name = 'Reference';
    end

    
    
    simoData = permute(simo.RDC_MF, [3,1,2]);
    simoData_angle = angle(simoData)*180/pi; % [deg]
    range_index_list = [52, 46];
    
    
    
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
        line(i) = plot(simoTest.slowTimeBins, angleDif, '.', 'DisplayName',legend_name, ...
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
    subtitle(t, 'Relative Spatial Phase Differences')
    title(t, save_name)
    saveas(fig, join(["../figures/spatial_phaseDif_", save_name, ".png"],''))
end

%%
a0 = 0.3636;
a1 = 0.4892;
a2 = 0.1366;
a3 = 0.0106;
N = 100;
n = 0:N-1;

w = a0 - a1*cos(2*n*pi/(N-1)+pi/2) + a2*cos(4*n*pi/(N-1)+pi) - a3*cos(6*n*pi/(N-1));
plot(n,w)


