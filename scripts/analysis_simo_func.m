function [] = analysis_simo_func(window, fname, cutoff, time_guess, subsampling)
    % The function input parameters are 

    % Window - the window function to be applied to the STFT spectrum. The
    % following will be accepted:
        % 'rectangular'
        % 'blackman'
        % 'blackman-harris
        % 'hamming'
    % fname - the fname of the simoTest folder. They have to lie in
    %         SIMO_data folder. the following will be accepted:
        % 'SIMO_data_Reference.mat'
        % 'SIMO_data_Prop-C.mat'
        % 'SIMO_data_Prop-B-Fast.mat'
        % 'SIMO_data_Prop-A-Fast.mat'
        % 'SIMO_data_Prop-A-Med.mat'
        % 'SIMO_data_Prop-A-Slow.mat'
    % cutoff - FLOAT: The threshold value used to separate noise from signal in
    %          the full spectrum
    % time_guess - the dwell time you want to use in the STFT. If
    %              time_guess is a number, this will be used as the 
    %              guess, but if it is 'auto', time_guess will be picked 
    %              as specified from cutoff value
    % subsampling - INTERGER: the subsampling value will be used to pick
    %               every n'th value from the SimoTest datastruct.

    % Load constants
    c = 3e8; % [m/s] speed of light
    f_c = 9.4e9; % [Hz]
    lambda_c = c/f_c; % [m]
    f_PRF = 62500 / subsampling

    % Wave_label 
    fname_split = split(fname, '.');
    save_name = char(extractAfter(fname_split(1), 10))
    
    % Wave data
    simoTest = load("../SIMO_data/" + fname);
    rangeBins = simoTest.rangeBins;
    slowTime = simoTest.slowTimeBins(1:subsampling:end);
    cplxData = simoTest.cplxData(:, 1:subsampling:end);
    rotor_signal = simoTest.x_signal(1:subsampling:end);

%     if strcmp(save_name, 'Prop-C')
%         rotor_signal = sum(simoTest.cplxData([7, 8, 9, 10], :));
%         rotor_signal = rotor_signal./max(abs(rotor_signal));
%     end

    
    %% mapping slow- and fast time
    % Load where the corner reflectors were placed
    reflector1 = 8.08; %[m]
    reflector2 = 23.90; %[m]
    
    % Create the figure
    fig = figure();
    hold on
    imagesc(slowTime*1e3, rangeBins, abs(cplxData))
    yline([reflector1, reflector2], 'r--', 'LineWidth',1.5)
    xlim([0, max(slowTime)])
    ylim([0, max(rangeBins)])
    xlabel('slow time [s]')
    ylabel('Range [m]')
    title(save_name)
    hold off
    saveas(fig,  join(['../figures/',save_name,'_slowFastTimeMap.png'], ''))
    
    %% mapping velocity power spectrum
    
    % Finding the true maximal radial velocity of rotor:
    if any(save_name == "c") % not "prop-C" nor "reference"
        v_max_est = 1e-12;
    else
        % The rotor radius is given as
        r_rotor = 0.36/2;
        
        % the rotor frequency is given as
        if all(save_name(end-3:end) == 'Fast')
            f_rotor = 50; %[Hz]
        elseif all(save_name(end-2:end) == 'Med')
            f_rotor = 27; %[Hz]
        elseif all(save_name(end-3:end) == 'Slow')
            f_rotor = 17; %[Hz]
        else 
            f_rotor = 1e-3;
        end
    
        % It seems that the rotor frequency is registered to be twice as
        % big as it is, so this is corrected for
        f_rotor_corrected = f_rotor/2;

        v_max_est = r_rotor*2*pi*f_rotor_corrected; % [m/s]
    end
    f_max_est = 2*v_max_est/lambda_c;

    % Isolate the signal for the range gates
    gate_signal = cplxData(simoTest.idxTarget, :);
    
    % create the spectrum 
    spectrum = fft(gate_signal.');
    % shift the spectrum so it is centered at f=0
    spectrum_shifted = fftshift(spectrum);
    % Find the power spectrum in dB
    spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));
    % Normalize the spectrum 
    spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB);
    % Define the frequency axis for the new spectrum
    fBins = linspace(-f_PRF/2, f_PRF/2,length(slowTime));
    % a Doppler measurement is given as f = 2v/lambda. To find velocity instead,
    vBins = lambda_c*fBins/2;
    
    % Load legend names for plotting 
    range_labels = repmat("range: ",4,1) + rangeBins(simoTest.idxTarget).'; 
    
    
    fig = figure();
    hold on
    for i = 1:4
        plot(vBins, spectrum_shifted_dB_norm(:, i), 'DisplayName', range_labels(i))
    end
    xline([-v_max_est, v_max_est], 'r--', 'DisplayName','maximum radial velocity of rotor', 'LineWidth',1.5)
    xlabel('Velocity [m/s]')
    ylabel('Normalized Power Spectrum [dB]')
    legend()
    legend(repmat("range: ",4,1) + rangeBins(simoTest.idxTarget).')
    title(join(['Spectrum of ', save_name]))
    saveas(fig, join(['../figures/',save_name,'_signalVelocityPower.png'], ''))

    
    fig = figure();
    hold on
    for i = 1:4
        plot(fBins*1e-3, spectrum_shifted_dB_norm(:, i), 'DisplayName', range_labels(i))
    end
    xline([-f_max_est, f_max_est]*1e-3, 'r--', 'DisplayName','maximum radial velocity of rotor', 'LineWidth',1.5)
    xlabel('frequency [kHz]')
    ylabel('Normalized Power Spectrum [dB]')
    legend()
    xlim(2/lambda_c*[-100, 100]*1e-3)
    title(join(['Spectrum of ', save_name]))
    hold off
    saveas(fig, join(['../figures/',save_name,'_signalVelocityPowerZoom.png'], ''))

    
    % Doing a full spectrum with the rotor signal rather than the range
    % gates

    spectrum_shifted_dB = 10*log10(abs(fftshift(fft(rotor_signal)))); %find the spectrum centered at f=0 in dB
    spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB); % normalize the spectrum

    fig=figure();
    hold on
    plot(fBins*1e-3, spectrum_shifted_dB_norm, 'DisplayName', range_labels(i))
    xline([-f_max_est, f_max_est]*1e-3, 'r--', 'DisplayName','maximum radial velocity', 'LineWidth',1.5)
    xlabel('frequency [kHz]')
    ylabel('Normalized Power Spectrum [dB]')
    legend()
    xlim(2*[-f_max_est, f_max_est]*1e-3)
    title(join(['Spectrum of ', save_name]))
    hold off
    saveas(fig, join(['../figures/',save_name,'_rotorSignalVelocityPowerZoom.png'], ''))
    
        
    %% Finding an estimate of time

    % Start by finding out how much the mainlobe is going to get widened by
    % our window function
    if strcmp(window,'blackman')
        dcExtension = 1.92;
    elseif strcmp(window,'blackman-harris')
        dcExtension = 2.22;
    elseif strcmp(window,'rectangular')
        dcExtension = 1;
    elseif strcmp(window,'hamming')
        dcExtension = 1.51;
    end

    % Find the maximum value of our Doppler spectrum (not noise)
    
    % Define spectrum
    spectrum_shifted_dB = 10*log10(abs(fftshift(fft(rotor_signal)))); %find the spectrum centered at f=0 in dB
    spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB); % normalize the spectrum
    % Define frequency bins
   fBins = linspace(-f_PRF/2, f_PRF/2,length(slowTime));
    
    
    % make a mask that removes all measurements below cutoff
    index = (spectrum_shifted_dB_norm > cutoff);
    
    maxDoppler = max(rmoutliers(fBins(index)));


    % Use the maximum Doppler value, the Doppler resoulution (our variable)
    % and the mainlobe widening (dcExtension) to find the best dwell time.
    % THE IMPORTANT EQUATION: 
    % dcExtension*fRes < maxDoppler   <=>   dcExtension/maxDoppler < TD
    % In this script 

    if ischar(time_guess) || isa(time_guess,'string')
        TD_guess = 3* dcExtension/maxDoppler;
    else
        TD_guess = time_guess;
    end

    %% Finding STFT of rotor signal - user defined window
    
    % To do the STFT of the signal
    %
    % tau - the slow time point we're trying to find the doppler shift of.
    % TD - Dwell time. +- T_D/2 on either side of tau
    % rotor_signal - the 1D signal we are trying to analyze.
    % ST - the slow time corresponding to each point in x_signal
    n_TD = floor(TD_guess*f_PRF);
    TD = n_TD/f_PRF;
    rotor_signal = rotor_signal;
    ST = slowTime;
    
    spacing = TD/4; % Define the spacing between elements in tau_list
    tau_list = (TD/2:spacing:max(ST)-TD/2);
    
    % create the frequency axis
    fBins = (-f_PRF/2: 1/TD :f_PRF/2);

    % Create the window to be used for STFT
    if strcmp(window,'blackman')
        w = blackman(n_TD).';
    elseif strcmp(window,'blackman-harris')
        w = blackmanharris(n_TD).';
    elseif strcmp(window,'rectangular')
        w = 1;
    elseif strcmp(window,'hamming')
        w = hamming(n_TD).';
    end
    
    matrix = zeros(n_TD, length(tau_list));
    % Create a spectrum for all time points in tau_list
    for i=1:length(tau_list)
        % Find the central time we want to analyze
        tau = tau_list(i);
        ST_index_tau = find(min(abs(ST-tau)) == abs(ST-tau));
        
        % Find the upper and lower bound from the central time and n_TD
        ST_index_lower_bound = ST_index_tau-floor(n_TD/2);
        ST_indexupper_bound = ST_index_tau+ceil(n_TD/2)-1;
        ST_index = ST_index_lower_bound:ST_indexupper_bound;
    


        % Create the new rotor signal with the appropriate window
        rotor_signal_blackman = rotor_signal(ST_index).*w;
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
    title(join([save_name, ', T_D = ', string(round(TD*1e3, 1)), ' ms'], ''))
    hold off
    saveas(fig, join(['../figures/',save_name,'_signalSTFT_blackmanWindow.png'], ''))


end







