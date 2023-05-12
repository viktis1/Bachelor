function  writeTCLscript(bool,SYS,waveformMode,saveDirectory)

% ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
%% ############################################### TCL-script handling ##################################################
% ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
if bool.writeTCLscript
    % Template file used depends on the version of the MIMO radar utilized
    if strcmp(SYS.Properties.MIMO_version, 'MS3')
        fileName = 'MIMO_DEMO_M3_recording_template.tcl';
    else
        fileName = 'MIMO_DEMO_M1_M2_recording_template.tcl';
    end

    fileID   = fopen(fileName);
    fileText = textscan(fileID, '%s');
    fileText = fileText{1};
    fclose(fileID);

    % Specific directory for custom TCL scripts
    % saveFolder = [pathWorkfolder, '\Lasse Demo Tools\Custom TCL scripts\'];
    % Introduce new-lines prior to each of the following commands
    lineCommands = {'#', 'dow', 'mrd', 'mwr', 'after', 'puts'};

    % Number of strings in file
    N_strings = numel(fileText);

    % Set registers according to test settings
    registerFields = fields(SYS.RegisterSpace);

    % Ignoring RX settings for BRAM if using MS3
    idxRegister = find(contains(registerFields,'set_') & ~contains(registerFields,'DDR') &  ~contains(registerFields,'set_RX_memoryUse')); 
    N_registers = numel(idxRegister);
    for n_reg = 1:N_registers
        tmpRegister = SYS.RegisterSpace.(registerFields{idxRegister(n_reg)});
        idxString = find(contains(fileText, tmpRegister{end}));
        fileText{idxString+1} = num2str(tmpRegister{1});
    end

    % Set waveforms for all channels  
    idxIQfiles = find(contains(fileText, '-data'))+1;
    for ii=1:numel(idxIQfiles)
        if strcmp(waveformMode,"TDM_Alternating") || strcmp(waveformMode,"TDM_Staggered") || strcmp(waveformMode,"SIMO") 
             fileText{idxIQfiles(ii)} = SYS.fileNameWaveform{1};
        elseif strcmp(waveformMode,"TDM_UpDown")
            if mod(ii,2)
                fileText{idxIQfiles(ii)} = SYS.fileNameWaveform{1};
            else
                fileText{idxIQfiles(ii)} = SYS.fileNameWaveform{2};
            end
        else
            fileText{idxIQfiles(ii)} = SYS.fileNameWaveform{ii};
        end
    end

    %     % Set timedelay for all channels 
    %     if SYS.txDelay 
    %         for ii=1:SYS.txNum 
    %             tmp = eval(['SYS.RegisterSpace.set_TX_delay_' num2str(ii-1)]);
    %             idx = find(contains(fileText, tmp{2}))+1;
    %             fileText{idx} = num2str(SYS.txDelayVec(ii)/SYS.RegisterSpace.maximum_TX_delay(2));
    %         end
    %     end 

    %% Set properly commented time-frames for script
    tmpList = find(contains(fileText, 'XXXX')); 
    fileText{tmpList(1)} = num2str(SYS.RegisterSpace.set_trigger_period_ms{1,1});
    fileText{tmpList(2)} = num2str(SYS.RegisterSpace.set_trigger_period_us{1,1});
    fileText{tmpList(3)} = num2str(SYS.RegisterSpace.set_RX_duration{1,1}*1e6*SYS.RegisterSpace.maximum_RX_duration(1,2));
    fileText{tmpList(4)} = num2str(SYS.RegisterSpace.set_RX_duration{1,1});

    % Waiting time for system between procedures 
    % Few more pauses in MS3 setup, and typically longer times allotted for
    % proper operation (just a few seconds in total)

    % Only add specific lines to capture delay if user has defined a
    % non-zero value
    tmpList = find(contains(fileText, 'after'))+1; 
    fileText{tmpList(1)} = num2str(ceil(SYS.totalObservationTime*1e3)+1000); % ms
    N_strings = numel(fileText);


    % Write TCL script with settings from current script
    fileName_TCL = [saveDirectory,'TCL_record_',waveformMode];
    fid = fopen([fileName_TCL, '.tcl'],'w');            % Open the file
    % For each string, write the data, add newline if certain string is
    % encountered

    for kk=1:N_strings
        if kk>1 && kk<= (N_strings-1) && sum(contains(lineCommands, fileText{kk+1})) >= 1
            tmp_cmd = lineCommands{find(contains( lineCommands, fileText{kk+1}))}; 
            % Safeguard against non-match cases
            if numel(fileText{kk+1}) == numel(tmp_cmd)
                fprintf(fid,'%s \n',fileText{kk});
            end
        else
            fprintf(fid,'%s ',fileText{kk});
        end
    end

%     if SYS.Properties.use_DDR_RAM
%         txtStr_01 = '# Use of DDR-RAM in the following line:';
%         txtStr_02 = 'puts "Downloading from DDR-RAM..."';
%         txtStr_03 = ['mrd -force -size b -bin -file adc_from_dma.bin ', SYS.RegisterSpace.set_DDR_RAM{1,2}, ' ', num2str(SYS.RegisterSpace.set_DDR_RAM{1,1})];
%         txtStr_04 = 'puts "***Download of data from DDR-RAM completed"';
%     %             fprintf(fid,'\n\n Units of MB \t %i \n%',txtStr_01, SYS.Properties.DDR_memoryUse_MB);
%     end
    fclose(fid);

    % ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 
    %% ##################################### TCL-scripts inserted for pauses in recording ######################################## 
    % ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 
    if bool.utilizePauseFiles
        % Template file used depends on the version of the MIMO radar utilized
        % (default is the latest)
        if strcmp(SYS.Properties.MIMO_version, 'MS3') 
            fileName = 'MIMO_DEMO_M3_pause_TX_template.tcl';
        end

        if nTest > 1 
            pauseName = [prefixNames{nTest}(1:2),'0',prefixNames{nTest}(3:end), ' - Pause']; 
            saveFolder_pause = [saveDirectory,'/', pauseName ];

            % Read-in file
            fileID   = fopen(fileName);
            fileText = textscan(fileID, '%s');
            fileText = fileText{1};
            fclose(fileID);

            % Specific directory for custom TCL scripts
            % saveFolder = [pathWorkfolder, '\Lasse Demo Tools\Custom TCL scripts\'];
            % Introduce new-lines prior to each of the following commands
            lineCommands = {'#', 'dow', 'mrd', 'mwr', 'after', 'puts'};

            % Number of strings in file
            N_strings = numel(fileText);

            % Set registers according to test settings
            registerFields = fields(SYS.RegisterSpace);


            % Only set the RX-duration
            tmpRegister             = SYS.RegisterSpace.set_RX_duration;
            tmpRegister{1}          = ceil(time_recordDeadtime / SYS.RegisterSpace.maximum_RX_duration(2)); % Replacing value expected from SYS
            % Determining the location of the address in the full string-array
            % of TCL-file and updating value
            idxString               = find(contains(fileText, tmpRegister{end}));
            fileText{idxString+1}   = num2str(tmpRegister{1});

            % Waiting time for system between procedures
            % Target pause-time to allow for code to execute
            tmpList = find(contains(fileText, 'after'))+1;
            fileText{tmpList(1)} = num2str(time_systemPause); % ms

            % Write TCL script with settings from current script
            if write_TCL_script == 1
                cdForce(saveFolder_pause);
                fid = fopen([fileName_TCL_deadTime, '.tcl'],'w');            % Open the file

                % For each string, write the data, add newline if certain string is
                % encountered
                for kk=1:N_strings
                    if kk>1 && kk<= (N_strings-1) && sum(contains(lineCommands, fileText{kk+1})) >= 1
                        tmp_cmd = lineCommands{find(contains( lineCommands, fileText{kk+1}))};
                        % Safeguard against non-match cases
                        if numel(fileText{kk+1}) == numel(tmp_cmd)
                            fprintf(fid,'%s \n',fileText{kk});
                        end
                    else
                        fprintf(fid,'%s ',fileText{kk});
                    end
                end

                fclose(fid);
            end
        end
    end

end

end

