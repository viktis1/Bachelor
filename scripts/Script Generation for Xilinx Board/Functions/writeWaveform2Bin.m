function writeWaveform2Bin(bool,SYS,waveform,saveDirectory)
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
%% ----------------------------------------------- Write IQ Files -------------------------------------------------- 
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
if bool.writeIQfiles
 %% Set standard values 
    % Set amplitudes - avoid the maximum value of 32767
    maxVal = +32767;
    minVal = -32768;

    % Value "-32767" not used, but easier just to multiple same number on for
    amp_sig = maxVal-1; 

    %% Check or updates and errors 
    % Possible reduction in full amplitude of signal 
    if SYS.ampModifier ~= 1
        amp_sig = amp_sig*SYS.ampModifier;
    end

%     % Error if TX memory is exceeded
%     if SYS.nSamplePulse > SYS.RegisterSpace.maximum_pulseLength(1)
%         error('The entire pulse / pulse sequence takes up more samples than available in TX memory (4096)');
%     end

    %% Write file
    if ~exist(saveDirectory,'dir'); mkdir(saveDirectory); end
        
    for nChannel = 1:SYS.waveformNum
        sig_I = round(real(waveform(:,nChannel)).*amp_sig); 
        sig_Q = round(imag(waveform(:,nChannel)).*amp_sig);

        sig_I(4096) = minVal; 
        sig_Q(4096) = minVal; 

        % File names for IQ-data
        fileName_tmp = [saveDirectory,SYS.fileNameWaveform{nChannel}];
        
        fp = fopen(fileName_tmp,'wb');
 
        for i=1:SYS.pulseSampleNum
            fwrite(fp,sig_I(i),'int16','ieee-le');
            fwrite(fp,sig_Q(i),'int16','ieee-le');
        end
        fclose(fp);
    end
end

end