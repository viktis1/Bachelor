%% ------------------------------------------------- Initialization ---------------------------------------------------
clear; close all; %clc;

% Directory management
workFolder    = pwd;
saveDirectory = [workFolder '\Output Scripts\'];
addpath(genpath(workFolder));

% Switchboard settings
bool.plotWaveformSchematics              = 1; % Plotting the generated waveforms to check time-delay, RX-duration and system trigger
bool.plotWaveformSpectrograms            = 1; 
bool.writeIQfiles                        = 1; % Write IQ-files for TX waveforms to save-directory
bool.writeTCLscript                      = 1; % Write TCL-control-script to save-directory
bool.utilizePauseFiles                   = 0; % Utilize special function for inserting break inbetween transmission of different waveforms

bool.printWaveformSettingsToConsole      = 1; % Print details regarding waveform selection in console´
bool.writeWaveformSettings               = 1; % Write details regarding waveform in TXT file and saving matlab structure

% Waveform List:
waveformModes   = {'TDM_Alternating',... % 1
                  'TDM_Staggered',...    % 2
                  'TDM_UpDown',...       % 3
                  'DDM',...              % 4
                  'Hadamard',...         % 5
                  'FDM',...              % 6
                  'Gold',...             % 7
                  'MultiCAN',...         % 8
                  'SIMO'};               % 9