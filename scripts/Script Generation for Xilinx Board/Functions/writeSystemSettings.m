function writeSystemSettings(bool,SYS,waveformMode,saveDirectory)

% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
%% ----------------------------------------------- Print information to user regard waveform selection -------------------------------------------------- 
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

    if bool.printWaveformSettingsToConsole
        % Print on console
        fprintf('Transmission scheme:       \t \t %s \n',             waveformMode);
        fprintf('Waveform selection:        \t \t %s \n',             SYS.waveformSelection);
        fprintf('TX-delay vector:           \t \t [%2.2f, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f] μs \n', SYS.txDelayVec*1e6);
        fprintf('Pulse duration:            \t \t %2.2f μs\n',        SYS.pulseLength*1e6);
        fprintf('RX duration:               \t \t %2.2f μs\n',        SYS.rxFrameDuration*1e6);
        fprintf('Pulse Repetition Interval: \t \t %2.0f μs\n',        SYS.PRI*1e6);
        fprintf('Pulse Repetition Frequency:\t \t %2.2f kHz\n',       SYS.PRF*1e-3);
        fprintf('Burst Length:              \t \t %2.0f pulses\n',    SYS.burstLength);
        fprintf('Burst Repetition Interval: \t \t %2.2f ms\n',        SYS.burstRI*1e3);
        fprintf('Burst Duty Cycle:          \t \t %3.2f %%\n\n',       SYS.PRI*SYS.burstLength/SYS.burstRI*100);

        fprintf('Range Resolution:          \t \t %2.2f m\n',         SYS.Properties.resRange);
        fprintf('Max. unamb. Range:         \t \t %2.2f km\n',        SYS.Properties.unambRange*1e-3);
        fprintf('Doppler Resolution:        \t \t %2.2f m/s\n',       SYS.Properties.resDoppler);
        fprintf('Max. unamb. Doppler:       \t \t \x00B1 %2.1f m/s\n\n',SYS.Properties.unambDoppler);

        if SYS.totalObservationTime > 1
            fprintf('Observation Time:          \t \t %2.2f s\n',SYS.totalObservationTime);
        else
            fprintf('Observation Time:          \t \t %2.2f ms\n',SYS.totalObservationTime*1e3);
        end
        fprintf('Memory Requirement:        \t \t %2.0f MB\n',SYS.memoryReq_MB);
        fprintf('Read-out Time:             \t \t %2.2f s\n',SYS.Properties.read_out_time);
    end

    if bool.writeWaveformSettings
        % Create File
        fileID = fopen([saveDirectory, 'Waveform Information_',waveformMode,'.txt'],'w');
        fprintf(fileID,'Transmission scheme:       \t \t %s \r\n',             waveformMode);
        fprintf(fileID,'Waveform selection:        \t \t %s \n',             SYS.waveformSelection);
        fprintf(fileID,'TX-delay vector:           \t \t [%2.2f, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f, %2.2f] μs \n', SYS.txDelayVec*1e6);
        fprintf(fileID,'Pulse duration:            \t \t %2.2f μs\n',        SYS.pulseLength*1e6);
        fprintf(fileID,'RX duration:               \t \t %2.2f μs\n',        SYS.rxFrameDuration*1e6);
        fprintf(fileID,'Pulse Repetition Interval: \t \t %2.0f μs\n',        SYS.PRI*1e6);
        fprintf(fileID,'Pulse Repetition Frequency:\t \t %2.2f kHz\n',       SYS.PRF*1e-3);
        fprintf(fileID,'Burst Length:              \t \t %2.0f pulses\n',    SYS.burstLength);
        fprintf(fileID,'Burst Repetition Interval: \t \t %2.2f ms\n',        SYS.burstRI*1e3);
        fprintf(fileID,'Burst Duty Cycle:          \t \t %3.2f %%\n\n',       SYS.PRI*SYS.burstLength/SYS.burstRI*100);


        fprintf(fileID,'Range Resolution:          \t \t %2.2f m\n',         SYS.Properties.resRange);
        fprintf(fileID,'Max. unamb. Range:         \t \t %2.2f km\n',        SYS.Properties.unambRange*1e-3);
        fprintf(fileID,'Doppler Resolution:        \t \t %2.2f m/s\n',       SYS.Properties.resDoppler);
        fprintf(fileID,'Max. unamb. Doppler:       \t \t \x00B1 %2.1f m/s\n\n',SYS.Properties.unambDoppler);


        if SYS.totalObservationTime > 1
            fprintf(fileID,'Observation Time:          \t \t %2.2f s\n',SYS.totalObservationTime);
        else
            fprintf(fileID,'Observation Time:          \t \t %2.2f ms\n',SYS.totalObservationTime*1e3);
        end
        fprintf(fileID,'Memory Requirement:        \t \t %2.0f MB\n',SYS.memoryReq_MB);
        fprintf(fileID,'Read-out Time:             \t \t %2.2f s\n',SYS.Properties.read_out_time);
        fclose(fileID);

        %% Export the settings used for the transmission as a MAT-file
        save([saveDirectory,'systemSettings_',waveformMode,'.mat'],'SYS');

    end

end