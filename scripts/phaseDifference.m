function [] = phaseDifference(fname)
    % fname - the fname of the simoTest folder. They have to lie in
    %         SIMO_data folder. the following will be accepted:
        % 'SIMO_data_Reference.mat'
        % 'SIMO_data_Prop-C.mat'
        % 'SIMO_data_Prop-B-Fast.mat'
        % 'SIMO_data_Prop-A-Fast.mat'
        % 'SIMO_data_Prop-A-Med.mat'
        % 'SIMO_data_Prop-A-Slow.mat'

    
    
    simo = load("../måling/rådata/RDC_MF_Propel A - Fast Speed_Wave 02 - SIMO_SIMO_burst001.mat") % unprocessed data