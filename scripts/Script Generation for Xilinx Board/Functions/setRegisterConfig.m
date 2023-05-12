function SYS = setRegisterConfig(SYS)
    % ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
    %% ----------------------------------------------- Register settings and default values -------------------------------------------------- 
    % ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
    SYS.Properties.MIMO_version        = 'MS3';
    SYS.Properties.captureDelay        = 0;
    if strcmp(SYS.Properties.MIMO_version,'MS3')
        SYS.Properties.use_DDR_RAM         = 1;
    else
        SYS.Properties.use_DDR_RAM         = 0;
    end
    SYS.Properties.dataTransferRate        = 300e6/8; % Divide by 8 due to units: bit/s
    
    % Values from registerspace                [numeric max. value,    unit/step-size (in sec or integer)]
    SYS.RegisterSpace.maximum_triggerPeriod_ms       	= [1024,        1];           % System trigger
    SYS.RegisterSpace.maximum_triggerPeriod_us       	= [999,         1];
    SYS.RegisterSpace.maximum_pulseLength            	= [4096,        1/256e6];
    SYS.RegisterSpace.maximum_TX_delay               	= [16383,       7.8125e-9];
    SYS.RegisterSpace.maximum_RX_delay               	= [4095,        62.5e-9];
    SYS.RegisterSpace.maximum_RX_duration            	= [32767,       62.5e-9];
    SYS.RegisterSpace.maximum_TX_burst_length        	= [65535,       1];
    SYS.RegisterSpace.maximum_TX_burst_pause         	= [65535,       1];

    % Values set for the various registers and their respective addresses

    % Trigger Period
    SYS.RegisterSpace.set_trigger_period_ms     = {floor(SYS.PRI*1e6./1000),    '0xA0040000'};
    SYS.RegisterSpace.set_trigger_period_us     = {ceil(mod(SYS.PRI*1e6,1000)), '0xA0040008'};
    
    % TX delay for each channels
    tmp = SYS.txDelayVec/SYS.RegisterSpace.maximum_TX_delay(2); 
    SYS.RegisterSpace.set_TX_delay_0            = {tmp(1),        		'0xA0041000'};
    SYS.RegisterSpace.set_TX_delay_1            = {tmp(2),        		'0xA0041008'};
    SYS.RegisterSpace.set_TX_delay_2           	= {tmp(3),        		'0xA0042000'};
    SYS.RegisterSpace.set_TX_delay_3           	= {tmp(4),        		'0xA0042008'};
    SYS.RegisterSpace.set_TX_delay_4          	= {tmp(5),        		'0xA0043000'};
    SYS.RegisterSpace.set_TX_delay_5           	= {tmp(6),        		'0xA0043008'};
    SYS.RegisterSpace.set_TX_delay_6           	= {tmp(7),        		'0xA0044000'};
    SYS.RegisterSpace.set_TX_delay_7           	= {tmp(8),        		'0xA0044008'};
    
    % Burst settings		
    SYS.RegisterSpace.set_TX_burst_length      	= {SYS.burstLength,     '0xA0045000'};
    SYS.RegisterSpace.set_TX_burst_pause       	= {SYS.burstPause,      '0xA0045008'};
    
    % RX settings for duration and delay
    tmp = SYS.rxFrameDuration/SYS.RegisterSpace.maximum_RX_delay(2); 
    SYS.RegisterSpace.set_RX_delay             	= {0,                   '0xA0046000'};
    SYS.RegisterSpace.set_RX_duration          	= {ceil(tmp),           '0xA0046008'};
    
    % TX channels enabled for use (default: all 8 channels on)		
    SYS.RegisterSpace.set_channel_enable        = {255,                 '0xA0047008'};

    
    % ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
    %% ----------------------------------------------- DDR-RAM usage w. MS2 -------------------------------------------------- 
    % ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
    SYS.RegisterSpace.kB_unit = 2^10;
    SYS.RegisterSpace.MB_unit = 2^20;
    SYS.RegisterSpace.GB_unit = 2^30;
    SYS.RegisterSpace.bytesPerSample = 4; % 32-bit samples

    % Approximately 4 Gigabytes available, minus 4 MB (not freed up according
    % to Jan, minor detail)
    SYS.RegisterSpace.maximum_TX_burst_pause         	= [(4*SYS.RegisterSpace.GB_unit - 4*SYS.RegisterSpace.MB_unit),       1]; % Register-value in bytes (shared amongst all 8 RX channels)
%     SYS.RegisterSpace.set_DDR_RAM                      = {1048576,         '0x500000000'};   % Default value mimics Jan's DDR-RAM example

    
    % ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
    %% ----------------------------------------------- Memory Requirements w. MS3 -------------------------------------------------- 
    % ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
    N_samples_RX    = SYS.RegisterSpace.set_RX_duration{1,1}*SYS.RegisterSpace.maximum_RX_duration(1,2)*SYS.fs;
    N_samples_total = N_samples_RX*SYS.burstLength*SYS.burstNum*SYS.txNum;

    memoryReq = SYS.RegisterSpace.bytesPerSample.*N_samples_total;
    SYS.memoryReq_MB    = ceil(memoryReq/SYS.RegisterSpace.MB_unit);
    memoryReq_bytes = SYS.memoryReq_MB*SYS.RegisterSpace.MB_unit;

    SYS.Properties.read_out_time               = memoryReq_bytes./SYS.Properties.dataTransferRate;

    if SYS.memoryReq_MB > 4095
        error('Maximum memory of 4 GB / 4096 MB for DDR-RAM exceeded - user specified: %i MB\n', SYS.memoryReq_MB);
    end

    % Ordering the structure alphabetically
    SYS = orderfields(SYS);

    
end
    