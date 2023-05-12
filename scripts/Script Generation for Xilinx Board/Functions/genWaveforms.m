function [SYS,waveform,saveDirectory] = genWaveforms(SYS,waveformMode,workFolder,saveDirectory) 

% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
%% ----------------------------------------------- System Struct -------------------------------------------------- 
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 

% If we want to change ampitude of signal

% Standard system settings (May be changed for specific waveforms)
SYS.B_sw            = 200e6;                      % Bandwidth Hz
SYS.fs              = 256e6;                      % Sampling Frequency Hz
SYS.txNum               = 8;                      % Number of tranmittters
SYS.waveformNum         = 8;                      % Number of different waveforms
SYS.pulseFrameNum       = 1;                      % Number of pulses for a single MIMO frame      
SYS.txDelay             = 0;                      % Delay across all channels in a single MIMO frame
SYS.waveformSelection   = "LinearFM";             % Waveform Category
SYS.rangeMaxCoeff       = 1;                      % Staggering Coefficient used for evaluating max range    
SYS.rangeResCoeff       = 1;                      % Range resolution coefficients (for FDM)
SYS.DopplerCoef         = 1;                      % Coefficient used for evaluating max Doppler    
SYS.ampModifier         = 1;                      % Amplitude modifier 

% Derived Waveform properties
SYS.pulseSampleNum        = SYS.pulseLength*SYS.fs;              % Samples 2: Independent of SYS.PRF, this value gives the number of samples for the pulse, exclusively
SYS.T                     = 1/SYS.fs;                     % Sample period 
SYS.Properties.timeOffset = 150/SYS.fs;             % Adding in TX/RX offset to compensate for assigned trigger

% Time vector only used for producing the waveforms
t = (((0:SYS.pulseSampleNum-1) - SYS.pulseSampleNum/2)*SYS.T);  

% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
%% ----------------------------------------------- Generate Waveforms -------------------------------------------------- 
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 

%% Alternating TIme-Division Multiplexing
if strcmp(waveformMode,"TDM_Alternating") 
    SYS.waveformNum = 1;   % Transmitting the same waveform for all channels
    SYS.txDelay = SYS.pulseLength;     

    phi = transpose(2*pi*(SYS.B_sw/(2*SYS.pulseLength)*t.^2));         % Phase of signal for each transmitter
    waveform = exp(1i*phi);
    waveform = (abs(waveform).*tukeywin(SYS.pulseSampleNum,0.08)).*exp(1i*(angle(waveform)));

    SYS.fileNameWaveform{1} =  'iq_sequence_TDM_Alternating.bin';

%% Staggered TDM 
elseif strcmp(waveformMode,"TDM_Staggered") 
    SYS.waveformNum = 1; % Transmitting the same waveform for all channels
    SYS.txDelay = SYS.pulseLength/SYS.txNum;   
    SYS.rangeMaxCoeff  = 1/SYS.txNum; 
            

    phi = transpose(2*pi*(SYS.B_sw/(2*SYS.pulseLength)*t.^2));         % Phase of signal for each transmitter
    waveform = exp(1i*phi);
    waveform = (abs(waveform).*tukeywin(SYS.pulseSampleNum,0.08)).*exp(1i*(angle(waveform)));
    
    SYS.fileNameWaveform{1} =  'iq_sequence_TDM_Staggered.bin';

%% Combined TDM and CDM from up-down chirps 
elseif strcmp(waveformMode,"TDM_UpDown") 
    SYS.waveformNum = 2; % Transmitting the same waveform for all channels
    SYS.txDelay = SYS.pulseLength/4;   
    SYS.rangeMaxCoeff  = 1/4; 
    
    phi = transpose(2*pi*(SYS.B_sw/(2*SYS.pulseLength)*t.^2));         % Phase of signal for each transmitter
    phi(:,2) = phi(:,1)*-1; 
    waveform = exp(1i*phi);
    waveform = (abs(waveform).*tukeywin(SYS.pulseSampleNum,0.08)).*exp(1i*(angle(waveform)));

    SYS.fileNameWaveform{1} =  'iq_sequence_TDM_UpDown_Up.bin';
    SYS.fileNameWaveform{2} =  'iq_sequence_TDM_UpDown_Down.bin';

%% DDM 
elseif strcmp(waveformMode,"DDM") 
    SYS.ampModifier = 0.3;
    SYS.DopplerCoef = 1/8;                      % Coefficient used for evaluating max Doppler    
    SYS.pulseFrameNum = 8; 
    SYS.pulseLength = SYS.pulseLength/8; 
    SYS.nSampleTmp = SYS.pulseSampleNum/SYS.txNum; 
    t_tmp = (((0:SYS.nSampleTmp-1) - SYS.nSampleTmp/2)*SYS.T);    %Time

    phi = transpose(2*pi*(SYS.B_sw/(2*SYS.pulseLength)*t_tmp.^2));

    waveform = exp(1i*phi);     
    waveform = repmat(waveform,1,SYS.txNum); 
    waveform = repmat(permute(waveform,[1,3,2]),1,SYS.txNum);

    phase = permute(repmat(wrapToPi(transpose(2*pi*(1/SYS.txNum)*(0:SYS.txNum-1))*(0:SYS.txNum-1)),1,1,SYS.nSampleTmp),[3,1,2]);    
    waveform = waveform.*exp(1i*phase);
    waveform = (abs(waveform).*tukeywin(SYS.nSampleTmp,0.05)).*exp(1i*(angle(waveform)));
    waveform = reshape(waveform,SYS.pulseSampleNum,8);

    fileNameWaveformTmp =  'iq_sequence_DDM';
%     freq = (0:SYS.nSampleTmp-1).*(SYS.fs/SYS.nSampleTmp)-SYS.fs/2;

%% HADAMARD
elseif strcmp(waveformMode,"Hadamard") 
    SYS.ampModifier = 0.3;
    SYS.DopplerCoef = 1/8;                      % Coefficient used for evaluating max Doppler    
    SYS.pulseFrameNum = 8; 
    SYS.pulseLength = SYS.pulseLength/8; 

    SYS.N_sample_tmp = 4096/SYS.txNum; 
    t_tmp = (((0:SYS.N_sample_tmp-1) - SYS.N_sample_tmp/2)*SYS.T);    %Time

    phi = transpose(2*pi*(SYS.B_sw/(2*SYS.pulseLength)*t_tmp.^2));
    waveform = exp(1i*phi); 
    waveform = repmat(waveform,1,SYS.txNum); 
    waveform = repmat(permute(waveform,[1,3,2]),1,SYS.txNum);

    H2 = [1 1;1 -1];
    code = H2; 
    for i_Tx = 1:log2(SYS.txNum)-1
        code = kron(H2,code); 
    end 
    code(code==1) = 0; 
    code(code==-1) = pi; 

    phase = permute(repmat(code,1,1,SYS.N_sample_tmp),[3,1,2]);    
    waveform = waveform.*exp(1i*phase);
    waveform = (abs(waveform).*tukeywin(SYS.N_sample_tmp,0.05)).*exp(1i*(angle(waveform)));
    waveform = reshape(waveform,4096,8);

    SYS.code = code;
    
    fileNameWaveformTmp =  'iq_sequence_Hadamard';            

%% FDM - Freqeuncy-Division Multiplexing
elseif strcmp(waveformMode,"FDM")    
    SYS.rangeResCoeff = 8; 
    
    t_tmp = (((0:SYS.pulseSampleNum*SYS.txNum-1) - SYS.pulseSampleNum*SYS.txNum/2)*SYS.T);                   %Time

    phi = 2*pi*(SYS.B_sw/(2*SYS.pulseLength*SYS.txNum)*t_tmp.^2);     %Phase of signal for each transmitter

    waveform = exp(1i*phi); 
    waveform = reshape(waveform,SYS.pulseSampleNum,SYS.txNum); 
    waveform = (abs(waveform).*tukeywin(SYS.pulseSampleNum,0.03)).*exp(1i*(angle(waveform)));

%         freq = (0:SYS.pulseSampleNum-1).*(SYS.fs/SYS.pulseSampleNum)-SYS.fs/2;
%         tmp = fftshift(fft(waveform(:,:,1)));
%         figure;plot(freq/1e6,mag2db(abs(tmp)))

    fileNameWaveformTmp =  '/iq_sequence_FDM';

%% GOLD-Codes    
elseif strcmp(waveformMode,"Gold") 
    SYS.nBitLength = 4096;
    
    SYS.waveformSelection = "Phase Modulation";             % Waveform Category    
    SYS.nBitLength = SYS.nBitLength-1; 

%     codeseq = genGoldCode(SYS.txNum,SYS.nBitLength); 
%     codeseq(end+1,:) = 0;     
%     P1 = 0; 
%     P2 = pi;
%     waveform = ((codeseq==1).*exp(1i*P1)+(codeseq==0).*exp(1i*P2)); 
       
    waveform = load([workFolder,'\Functions\cdmWaveformLUT\',waveformMode,'_',num2str(SYS.nBitLength+1),'.mat'],'waveform');
    waveform = waveform.waveform;

%     fileNameWaveformTmp =  ['iq_sequence_',num2str(SYS.nBitLength+1)];    
    fileNameWaveformTmp =  'iq_sequence_Gold';          


%% MULTI-CAN
elseif strcmp(waveformMode,"MultiCAN") 
    SYS.nBitLength = 4096;
    
    SYS.waveformSelection = "Phase Modulation";             % Waveform Category
    SYS.nBitLength = SYS.nBitLength-1; 

    waveform = load([workFolder,'\Functions\cdmWaveformLUT\',waveformMode,'_',num2str(SYS.nBitLength+1),'.mat']);
    waveform = waveform.waveform;
%     waveform = genCanCode(SYS.nBitLength,SYS.txNum);
%     waveform(end+1,:) = 0;     
    fileNameWaveformTmp =  'iq_sequence_MultiCAN';          
%     fileNameWaveformTmp =  ['iq_sequence_',num2str(SYS.nBitLength+1)];          

%% SIMO 
elseif strcmp(waveformMode,"SIMO") 
    SYS.waveformNum     = 1;   % Transmitting the same waveform for all channels
    % Note - SYS.txDelay left out, as to ensure simulatnaous transmission
    % of LFM
    phi                 = transpose(2*pi*(SYS.B_sw/(2*SYS.pulseLength)*t.^2));         % Phase of signal for each transmitter
    waveform            = exp(1i*phi);
    waveform            = (abs(waveform).*tukeywin(SYS.pulseSampleNum,0.08)).*exp(1i*(angle(waveform)));

    SYS.fileNameWaveform{1} =  'iq_sequence_SIMO.bin';
    
    %%
end

saveDirectory = [saveDirectory,waveformMode,'\'];
        

%% Setting Waveform Parameters Related to MIMO Frames 
if strcmp(waveformMode,"TDM_UpDown")
    SYS.txDelayVec   = reshape(repmat((0:3)*SYS.txDelay,2,1),1,8);
else
    SYS.txDelayVec   = (0:7).*SYS.txDelay;
end

% % Low-pass filter desinged for spread-spectrum signal (wideband)
% if strcmp(SYS.waveformSelection,"Phase Modulation")
%     % Filter coefficients seem to be decent selection, assuming sampling rate of 256 MHz, but <200 MHz bandwidth available at RF-stage
%     N_order = 90;
%     b = cfirpm(N_order,[-1 -0.75  -0.675  0.675  0.75  1],@lowpass);
%     % Apply low-pass filter
%     for kk=1:SYS.txNum
%         x_tmp = waveform(:,kk);
%         x_tmp = filter(b,1,x_tmp);
%         x_tmp = x_tmp./max(abs(x_tmp)); % Ensure to normalize - keep within ADC-limits for later conversion in export-script
%         waveform(:,kk) = x_tmp;
%     end
%     if saveCode
%         save([saveDirectory,'waveform_',num2str(SYS.nBitLength+1)],'waveform')
%     end
% end    

% Pulse settings
SYS.rxFrameDuration     = (SYS.pulseLength + max(SYS.txDelayVec))*SYS.pulseFrameNum + SYS.Properties.timeOffset; 
SYS.rxFrameDuration     = 62.5e-9*ceil(SYS.rxFrameDuration/62.5e-9); 
SYS.PRI                 = ceil(SYS.rxFrameDuration/(SYS.duty/100)*1e6)/1e6;  % Pulse Repetition Interval rounded up to nearest us    
SYS.PRF                 = 1/SYS.PRI;                                        % Pulse Repetition Frequency

% Burst settings
SYS.burstTime          = SYS.burstLength*SYS.PRI; 
SYS.burstRI            = 1/SYS.burstRF;
if SYS.burstRI >= SYS.burstTime
    SYS.burstPause         = ceil((SYS.burstRI-SYS.burstTime)/SYS.PRI);    % burst Pause has to be an integer. Hence BRI and BRF should be updated
else
    error('Burst Repetition Interval is smaller than burst duration. Please decrease Burst Repetition Frequency or decrease burst length'); 
end
% Update BRI and BRF 
SYS.burstRI            = (SYS.burstLength+SYS.burstPause)*SYS.PRI; 
SYS.burstRF            = 1/SYS.burstRI;

SYS.totalObservationTime    = SYS.burstRI*SYS.burstNum; 

% Set system properties 
SYS.Properties.c                = physconst('LightSpeed'); 
SYS.Properties.rfFreq           = 9.4e9; 
SYS.Properties.resRange         = SYS.Properties.c/(2*SYS.B_sw)*SYS.rangeResCoeff; 
SYS.Properties.resDoppler       = SYS.Properties.c/(SYS.burstTime*2*SYS.Properties.rfFreq); 
SYS.Properties.unambTime        = SYS.pulseLength*SYS.rangeMaxCoeff; 
SYS.Properties.unambRange       = SYS.Properties.unambTime*SYS.Properties.c/2;
SYS.Properties.unambDoppler     = SYS.Properties.resDoppler*SYS.burstLength/2*SYS.DopplerCoef;

% Set waveform Name
if ~strcmp(waveformMode,"TDM_Alternating") && ~strcmp(waveformMode,"TDM_Staggered") && ~strcmp(waveformMode,"TDM_UpDown") && ~strcmp(waveformMode,"SIMO")
    SYS.fileNameWaveform = cell(1,SYS.waveformNum);
    for nChannel = 1:SYS.txNum 
        SYS.fileNameWaveform{nChannel} = [fileNameWaveformTmp,'_CH',num2str(nChannel),'.bin'];
    end 
end


end

