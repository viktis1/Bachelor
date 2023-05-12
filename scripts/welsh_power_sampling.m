% welsh_power_sampling('SIMO_data_Prop-A-Fast.mat', 3, 'blackman-harris')

function [] = welsh_power_sampling(fname, dMax, window_name)
    % The function input parameters are 
    % 
    % fname - the fname of the simoTest folder. They have to lie in
    %         SIMO_data folder. the following will be accepted:
        % 'SIMO_data_Reference.mat'
        % 'SIMO_data_Prop-C.mat'
        % 'SIMO_data_Prop-B-Fast.mat'
        % 'SIMO_data_Prop-A-Fast.mat'
        % 'SIMO_data_Prop-A-Med.mat'
        % 'SIMO_data_Prop-A-Slow.mat'
    % dMax - the amount of groups to be used for welsh power sampling
    
    % Defining constants and random seed
    f_PRF = 62500;
    rng(1);

    % Wave_label 
    fname_split = split(fname, '.');
    save_name = char(extractAfter(fname_split(1), 10));

    if strcmp(save_name(end-5:end), 'A-Fast')
        plotName = 'Rotor 24 Hz'
    elseif strcmp(save_name(end-4:end), 'A-Med')
        plotName = 'Rotor 13 Hz'
    elseif strcmp(save_name(end-5:end), 'A-Slow')
        plotName = 'Rotor 9 Hz'
    elseif strcmp(save_name(end-5:end), 'B-Fast')
        plotName = 'Al. Rotor 24 Hz'
    else
        plotName = save_name
    end
    
    % Wave data
    simoTest = load("../SIMO_data/" + fname);
    
    % Create the window to be used in time window
    N = floor(length(simoTest.slowTimeBins)/dMax); % Defining the length of ST intervals
    if strcmp(window_name,'blackman')
        w = blackman(N).';
    elseif strcmp(window_name,'blackman-harris')
        w = blackmanharris(N).';
    elseif strcmp(window_name,'rectangular')
        w = 1;
    elseif strcmp(window_name,'hamming')
        w = hamming(N).';
    end

    % Dividing the data into the groups
    matrix = zeros(N, dMax); % define a matrix for collecting data  
    for i=0:(dMax-1)
        % Defining subdata and loading the spectrum of the subdata
        data = w.*simoTest.x_signal(:, (i*N+1):(i*N+N));
        spectrum = fft(data);
        spectrum_shifted = fftshift(spectrum);
        spectrum_shifted_power = abs(spectrum_shifted).^2;
%         spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));

        % Load the spectrum into a matrix
        matrix(:, i+1) = spectrum_shifted_power;

    end

    % Create the welsh power spectrum 
    spectrum_shifted_welsh = sum(matrix, 2);
    spectrum_shifted_welsh_dB = 10*log10(sqrt(spectrum_shifted_welsh));
    spectrum_shifted_welsh_dB_norm = spectrum_shifted_welsh_dB - max(spectrum_shifted_welsh_dB);

    % Defining the frequency axis
    f = linspace(-f_PRF/2, f_PRF/2, N); % [Hz]
    

    % Cluster the data
%     X = [f.'*1e-3, spectrum_shifted_dB_welsh_norm];
    [idx, C] = kmeans(spectrum_shifted_welsh_dB_norm, 2, 'Distance', 'sqeuclidean');

    rotor_group = find(C==max(C));
    f_rotor = rmoutliers(f(idx==rotor_group));
    rotor_limit = min([-min(f_rotor), max(f_rotor)]);
    idx_rotor= (f > min(f_rotor)) & (f < max(f_rotor));
%     idx_rotor= (f > -rotor_limit) & (f < rotor_limit);
    

    % Create a figure
    fig = figure();
    hold on
    plot(f(idx_rotor)*1e-3, spectrum_shifted_welsh_dB_norm(idx_rotor), 'r')
    plot(f(~idx_rotor)*1e-3, spectrum_shifted_welsh_dB_norm(~idx_rotor), 'b')
    xlabel('Frequency [kHz]')
    ylabel('Normalized Power Spectrum [dB]')
    xlim(3*[-rotor_limit, rotor_limit]*1e-3)
    title(plotName)
    subtitle(join(['groups = ', num2str(dMax)], ''))
    saveas(fig, join(['../figures/',save_name,'_welshPowerSampling', num2str(dMax), '.png'], ''))

end


