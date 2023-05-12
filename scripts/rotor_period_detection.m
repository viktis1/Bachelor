% rotor_period_detection('SIMO_data_Prop-B-Fast.mat', true)

function [] = rotor_period_detection(fname, saveMode)
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


    % Defining constants
    f_PRF = 62500;

    % Wave_label 
    fname_split = split(fname, '.');
    save_name = char(extractAfter(fname_split(1), 10))

    % Plot name
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

    % append zeros since the autocorrelation function makes the function
    % twice as long
    rotor_signal = [simoTest.x_signal, zeros(size(simoTest.x_signal))];
    slow_time = [simoTest.slowTimeBins, simoTest.slowTimeBins+ max(simoTest.slowTimeBins)];

    % Load the spectrum and find the squared magnitude.
    spectrum = fft(rotor_signal);
    spectrum_magnitude_sq = abs(spectrum).^2;

    % Define the cepstrum and autocorrelation
    C = abs(ifft(log(spectrum_magnitude_sq))).^2;
%     C = C(100:end-100); % Limit the spectrum, because the zero-point is soooo high relative to the others
    C_db_norm = 10*log10(C) - 10*log10(max(C));
    A = abs(ifft(spectrum_magnitude_sq));
    A_db_norm = 10*log10(A) - 10*log10(max(A)); 

    [idx_max_A, P_A] = islocalmax(A_db_norm);
    [idx_max_C, P_C] = islocalmax(A_db_norm);

    % Create time axis centered at 0 and fftshift the autocorrelationa and Cepstrum
    t_plot = [-flip(simoTest.slowTimeBins), simoTest.slowTimeBins];
    C_db_norm_centered = fftshift(C_db_norm);
    A_db_norm_centered = fftshift(A_db_norm);
    A_db_norm_centered_enlarged = A_db_norm_centered*1;

    % Don't do this if no maxima are detected
    if sum(idx_max_A) ~= 0
        % Find the maximum value. If there are 2 points with this value,
        % pick the one with shortest time. Then find the rotor period.
        idx_maximum_shifted_A_list = find(fftshift(P_A) == max(P_A(idx_max_A)));
        [~, I] = min(abs(t_plot(idx_maximum_shifted_A_list)));
        idx_maximum_shifted_A = idx_maximum_shifted_A_list(I);

        rotor_period_A = slow_time(idx_maximum_shifted_A);
        rotor_period_A = min([rotor_period_A, max(slow_time)-rotor_period_A]);
    end % Don't do this if no maxima are detected

    if sum(idx_max_C) ~= 0
        % Find the maximum value. If there are 2 points with this value,
        % pick one. Then find the rotor period.
        idx_maximum_shifted_C_list = find(fftshift(P_C) == max(P_C(idx_max_C)))
        [~, I] = min(abs(t_plot(idx_maximum_shifted_A_list)));
        idx_maximum_shifted_C = idx_maximum_shifted_C_list(I);

        idx_maximum_shifted_C = idx_maximum_shifted_C(1);
        rotor_period_C = slow_time(idx_maximum_shifted_C);
        rotor_period_C = min([rotor_period_C, max(slow_time)-rotor_period_C]);
    end


   

    % Create a figure for cepstrum
    fig = figure();
    hold on
%     plot(t_plot(100:end-100), C_db_norm_centered, 'DisplayName','Cepstrum; Rect')
    plot(t_plot, C_db_norm_centered, 'DisplayName','Cepstrum; Rect')
    plot(t_plot, A_db_norm_centered_enlarged, 'DisplayName','Autocorrelation; Rect')
    if sum(idx_max_A ~=0)
%         plot(t_plot(fftshift(idx_max_A)), A_db_norm_centered(fftshift(idx_max_A)), 'g*', 'DisplayName','Maxima')
        plot(t_plot(idx_maximum_shifted_A), A_db_norm_centered_enlarged(idx_maximum_shifted_A), 'r*', 'DisplayName','Maximum')
    end
    if sum(idx_max_C ~=0)
        plot(t_plot(fftshift(idx_max_C)), C_db_norm_centered(fftshift(idx_max_C)), 'g*', 'DisplayName','Maxima')
        plot(t_plot(idx_maximum_shifted_C), C_db_norm_centered(idx_maximum_shifted_C), 'r*', 'DisplayName','Maximum')
    end
    xlabel('Slow Time [s]')
    ylabel('Normalized Magnitude [dB]')
    ylim([-70, 0])
    xlim([-0.1, 0.1])
    legend('Location','northeast')
    title(plotName)
    if saveMode == 1
        saveas(fig, join(['../figures/',save_name,'_rotorPeriod.png'], ''))
    end
    
    
    
end


