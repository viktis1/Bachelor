% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
%% --------------------------------- Script Generation --------------------------------
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Initialize
%---------------------------------- Parameter Selection -------------------------------
waveformMode = 'SIMO';
waveformMode = 'TDM_Staggered';

if strcmp(waveformMode, 'TDM_Staggered')
    % System Settings
    SYS.pulseLength     = 8e-6;       % Pulse Length in us
elseif strcmp(waveformMode, 'SIMO')
    % System Settings
    SYS.pulseLength     = 15e-6;       % Pulse Length in us
end
    
SYS.duty            = 100;          % Duty Cycle in percentage
SYS.burstLength     = 32768/8; %32768;         % Burst Length (Number of system triggers/pulses)
SYS.burstRF         = 1;           % Burst Repetition Frequencuy
SYS.burstNum        = 8;          % Number of bursts

% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
%% ----------------------------------Background Code ------------------------------------
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
% Generate Waveforms
[SYS,waveform,saveDirectory] = genWaveforms(SYS,waveformMode,workFolder,saveDirectory);

% Load all register configurations
SYS = setRegisterConfig(SYS);

% Generate IQ waveform file
writeWaveform2Bin(bool,SYS,waveform,saveDirectory)

% Generate TCL Script
writeTCLscript(bool,SYS,waveformMode,saveDirectory);

% Plotting waveforms
plotWaveforms(bool,SYS,waveformMode,waveform)

% Print and/or write system settings
writeSystemSettings(bool,SYS,waveformMode,saveDirectory)



