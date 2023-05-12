function[] = parameter_plot(window, myFiles, cutoff, k)
    %
    % myFiles: A list of the names of files you want to analyze. MUST BE
    % STRINGS
    % window: the time window to use 
    % folder_name: the folder in which your.mat files lie
    % cutoff: the threshold value in which the data is sorted
    % k: the constant to use for finding Dwell time. Can be a vector
    
    
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
    
    
        
    fig = figure();
    fig.Position = [100, 100, 1200, 700]
    hold on
    
    % Iterate through all the files
    for b = 1:length(myFiles)
        % Find the filename and from this define the rotor speed
        fileName = char(myFiles(b))
        experimentName = extractBefore(extractAfter(fileName, 10), length(extractAfter(fileName, 10))-3); % Load the central part of word
%         experimentName(end-5:end)
        if strcmp(experimentName(end-5:end), 'A-Fast')
            plotName = 'Rotor 24 Hz'
        elseif strcmp(experimentName(end-4:end), 'A-Med')
            plotName = 'Rotor 13 Hz'
        elseif strcmp(experimentName(end-5:end), 'A-Slow')
            plotName = 'Rotor 9 Hz'
        elseif strcmp(experimentName(end-5:end), 'B-Fast')
            plotName = 'Al. Rotor 24 Hz'
        end

        simoTest = load("../SIMO_data/"+fileName);
        
        for j = 1:length(k)
            % Define spectrum
            spectrum_shifted_dB = 10*log10(abs(fftshift(fft(simoTest.x_signal)))); %find the spectrum centered at f=0 in dB
            spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB); % normalize the spectrum
            % Define frequency bins
            f_PRF = 62.5e3;
            fBins_full = linspace(-f_PRF/2, f_PRF/2,length(simoTest.slowTimeBins));
            
            % make a mask that removes all measurements below cutoff
            index = (spectrum_shifted_dB_norm > cutoff);
            maxDoppler = max(rmoutliers(fBins_full(index)));
    
            % Find the Td_guess
            TD_guess = k(j)* dcExtension/maxDoppler;
            
            % Find time as a multiple of PRF
            n_TD = floor(TD_guess*f_PRF);
            TD = n_TD/f_PRF
    
            % Define the central times in our STFT, the ST bins and freq bins
            ST = simoTest.slowTimeBins;
            fBins = (-f_PRF/2: 1/TD :f_PRF/2);
            tau_list = (TD/2:TD/4:max(ST)-TD/2);
    
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
           
            matrix = ones(n_TD, length(tau_list));
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
                rotor_signal_blackman = simoTest.x_signal(ST_index).*w;
                % Create the spectrum and then shift it.
                % Change the measurement unit to dB and then normalize the spectrum
                spectrum = fft(rotor_signal_blackman);
                spectrum_shifted = fftshift(spectrum);
                spectrum_shifted_dB = 10*log10(abs(spectrum_shifted));
                spectrum_shifted_dB_norm = spectrum_shifted_dB - max(spectrum_shifted_dB);
                
                matrix(:, i) = spectrum_shifted_dB_norm;
            end
            
    
            ax(length(myFiles)*(j-1) + b) = subplot(length(k), length(myFiles), length(myFiles)*(j-1) + b);
            hold on
            imagesc(tau_list*1e3, fBins*1e-3, matrix)
            xlim([0, max(tau_list*1e3)])
            ylim(3*[-maxDoppler*1e-3, maxDoppler*1e-3])
            clim([-60, 0])
    
            if j==1
                tit = title(plotName);
                tit.FontSize = 12;
                xticks([])
            elseif j == length(k)
                xlabel('Time [mS]')
            else
                xticks([])
            end


            td_tit = subtitle(join(['T_D = ', string(round(TD*1e3, 1)), ' ms'], ''));
            td_tit.FontSize = 8;
        end
    end
    cb = colorbar();
    cb.Location = 'manual';
    cb.Position = [0.93, 0.05, 0.02, 0.85];

    ylabel(cb, 'Normalized Power [dB]')
    linkaxes(ax, 'x')

    for i =1:(length(k)*length(myFiles))
        vertical = -0.05*floor(i/length(myFiles))/length(k);
        pos = get(ax(i), 'Position') + [-0.03, vertical, 0.02, 0.02]
        set(ax(i), 'Position', pos)
        

        if rem(i-1, length(myFiles)) == 0
            title_string = join(['k =', num2str(k( (i-1)/length(myFiles)+1  ))])
            annotation('textbox', pos+[-0.045,0.0,0,0], 'string', title_string, ...
                'EdgeColor','none', 'FontSize',10, 'FontWeight','bold')
            annotation('textbox', pos+[-0.06,-0.02,0,0], 'string', 'Freq. [kHz]', ...
                'EdgeColor','none', 'FontSize',8)
        end
    end
    saveas(fig, '../figures/parameter_tuning_TD.png')
end