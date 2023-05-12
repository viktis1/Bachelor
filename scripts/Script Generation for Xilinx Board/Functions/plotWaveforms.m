function plotWaveforms(bool,SYS,waveformMode,waveform)


% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
%% ----------------------------------------------- Plot Waveform Schematics -------------------------------------------------- 
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 

if bool.plotWaveformSchematics|| bool.plotWaveformSpectrograms
fontSize            = 12;
LW                  = 'LineWidth';
LW2                 = 1.4;
LW3                 = 2.5;
axisBeautify        = 0;
CMap_lines          = dlmread('CMap_newPalette.txt');

y_val = [-SYS.B_sw/2, SYS.B_sw/2].*1e-6;
x_val = [0, SYS.pulseLength*SYS.pulseFrameNum].*1e6;
if strcmp(waveformMode,'Gold') || strcmp(waveformMode,'MultiCAN') 
    adjust_y_val = 0.9;
    N_plotPoints = 32;
    x_wavePlot = linspace(x_val(1), x_val(2), N_plotPoints);
    y_wavePlot = round(rand_spec(-1, 1, [N_plotPoints,1])).*abs(adjust_y_val*y_val(1));
else
    adjust_y_val = 0.99;
    x_wavePlot = [0, SYS.pulseLength].*1e6;
    y_wavePlot = y_val.*adjust_y_val;
end

if strcmp(waveformMode,"FDM")
    y_wavePlot = y_wavePlot/8-3.5*SYS.B_sw/1e6/8; 
end
% x_max = x_val(end)*SYS.txNum;
x_SYS_max = SYS.pulseLength*1e6;
% x_RX_max  = SYS.RegisterSpace.set_RX_duration{1}*SYS.RegisterSpace.maximum_RX_duration(2)*1e6;
x_RX_max  = (SYS.RegisterSpace.set_RX_duration{1}*SYS.RegisterSpace.maximum_RX_delay(2))*1e6;

end
if bool.plotWaveformSchematics 
    ignorePlots = 1;
    if ignorePlots == 0
        % Not as good overview as the following figure
        figure(); ROW = 8; COL = 1;
        for iTX=1:SYS.txNum
            subplot(ROW,COL,iTX);
            plot([0, x_SYS_max], [0, 0],'k--',LW, LW2);
            hold on;
            %         plot(x_val + (SYS.txDelayVec(ii).*1e6), y_val, 'color', CMap_lines(ii,:), LW, LW2);
            if strcmp(SYS.waveformSelection,"Phase Modulation")
                y_wavePlot = round(rand_spec(-1, 1, [N_plotPoints,1])).*abs(adjust_y_val*y_val(1));
                stairs(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot, 'color', CMap_lines(iTX,:), LW, LW2);
            else
                plot(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot, 'color', CMap_lines(iTX,:), LW, LW2);
            end
            hold off;
        end
    end

    y_max = (SYS.txNum.*y_val(2)*2);

    kk = 1; clear hPlot
    figure('Name', 'Waveform scheduling'); 
    subplot('Position',[0.1 0.1 0.8, 0.8])
%     plot([0, x_SYS_max], [-1,-1].*y_max/2,'k:',LW, LW2);
    hold on;
    for iTX=1:SYS.txNum
        %         plot(x_val + (SYS.txDelayVec(ii).*1e6), y_val - y_max*((ii-1)/SYS.txNum), 'color', CMap_lines(ii,:), LW, LW3);
        if strcmp(SYS.waveformSelection,"Phase Modulation")
            y_wavePlot = (round(rand_spec(0, 1, [N_plotPoints,1])).*abs(adjust_y_val*y_val(1))*2)-abs(adjust_y_val*y_val(1));
            stairs(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum), 'color', CMap_lines(iTX,:), LW, LW3);
        else
            if strcmp(waveformMode,"DDM")
                for iPulse = 1:8
                    plot(x_wavePlot+x_wavePlot(2)*(iPulse-1) + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum), 'color', CMap_lines(iTX,:), LW, LW3);
                end
            elseif strcmp(waveformMode,"Hadamard") 
                for iPulse = 1:8
                    if SYS.code(iTX,iPulse)
                        plot(x_wavePlot+x_wavePlot(2)*(iPulse-1) + (SYS.txDelayVec(iTX).*1e6), fliplr(y_wavePlot - y_max*((iTX-1)/SYS.txNum)), 'color', CMap_lines(iTX,:), LW, LW3);
                    else
                        plot(x_wavePlot+x_wavePlot(2)*(iPulse-1) + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum), 'color', CMap_lines(iTX,:), LW, LW3);
                    end
                end
            elseif strcmp(waveformMode,"FDM") 
                    plot(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum)+SYS.B_sw/1e6/8*(iTX-1), 'color', CMap_lines(iTX,:), LW, LW3);
            else
                if strcmp(waveformMode,"TDM_UpDown") && mod(iTX,2) == 0
                    plot(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), fliplr(y_wavePlot - y_max*((iTX-1)/SYS.txNum)), 'color', CMap_lines(iTX,:), LW, LW3);
                else
                    plot(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum), 'color', CMap_lines(iTX,:), LW, LW3);
                end
            end
        end

        x_fill = [x_val(1), x_val(1), x_val(2), x_val(2)]  + (SYS.txDelayVec(iTX).*1e6);
        y_fill = [y_val(1), y_val(2), y_val(2), y_val(1)]  - y_max*((iTX-1)/SYS.txNum);

        fill(x_fill, y_fill,CMap_lines(iTX,:),'FaceAlpha',0.35);
    end
    n_pointsTrigger = 10;
    hPlot(kk) = plot(ones(n_pointsTrigger,1).*SYS.pulseLength.*1e6, linspace((SYS.B_sw/2*1e-6), -y_max + (SYS.B_sw/2*1e-6), n_pointsTrigger), 'k--', LW, LW3); kk = kk+1;
    hPlot(kk) = plot(ones(n_pointsTrigger,1).*SYS.rxFrameDuration.*1e6, linspace((SYS.B_sw/2*1e-6), -y_max + (SYS.B_sw/2*1e-6), n_pointsTrigger), 'b--', LW, LW3); kk = kk+1;
    hPlot(kk) = plot(ones(n_pointsTrigger,1).*SYS.PRI.*1e6, linspace((SYS.B_sw/2*1e-6), -y_max + (SYS.B_sw/2*1e-6), n_pointsTrigger), 'r--', LW, LW3); kk = kk+1;
%     hPlot(kk) = plot([0, x_RX_max],(-y_max + (SYS.B_sw/2*1e-6)).*[1,1], 'ms-', LW, LW3); kk = kk+1;
    hold off;
    FigText('Waveform scheduling within the 1st PRI','Time [\mus]','TX channels',fontSize, fontSize);
    sgtitle(strjoin(['Waveform selection: ', waveformMode,' using ', SYS.waveformSelection]), 'fontsize', fontSize+2); 
    set(gca,'ytick',-1400:200:0); set(gca,'yticklabel',{'CH8','CH7','CH6','CH5','CH4','CH3','CH2','CH1',});
    legend(hPlot,'Pulse Length','RX-duration','PRI/System Trigger');
    box on; 
    %     set(gca,'ycolor', 'none');
    if axisBeautify == 1
        set(gca,'xtick',[], 'ytick',[]);
        set(gca, 'xcolor', 'none', 'ycolor', 'none');
    end

    %% Show all pulses in view
    evaluate_pulse_schedule = 0;
    if evaluate_pulse_schedule
        figure(); ROW = 8; COL = 1;
        plot([0, x_SYS_max], [-1,-1].*y_max/2,'k:',LW, LW2);
        hold on;
        for jj=1:N_pulses
            for iTX=1:N_sequences
                %         plot(x_val + (SYS.txDelayVec(ii).*1e6), y_val - y_max*((ii-1)/SYS.txNum), 'color', CMap_lines(ii,:), LW, LW3);
                if strcmp(SYS.waveformSelection,"Phase Modulation")
                    y_wavePlot = round(rand_spec(-1, 1, [N_plotPoints,1])).*abs(adjust_y_val*y_val(1));
                    stairs(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum), 'color', CMap_lines(iTX,:), LW, LW3);
                else
                    plot(x_wavePlot + (SYS.txDelayVec(iTX).*1e6), y_wavePlot - y_max*((iTX-1)/SYS.txNum), 'color', CMap_lines(iTX,:), LW, LW3);
                end

                x_fill = [x_val(1), x_val(1), x_val(2), x_val(2)]  + (SYS.txDelayVec(iTX).*1e6);
                y_fill = [y_val(1), y_val(2), y_val(2), y_val(1)]  - y_max*((iTX-1)/SYS.txNum);

                fill(x_fill, y_fill,CMap_lines(iTX,:),'FaceAlpha',0.35);
            end
            n_pointsTrigger = 10;
            plot(ones(n_pointsTrigger,1).*SYS.rxFrameDuration.*1e6, linspace(0, -y_max + (SYS.B_sw/2*1e-6), n_pointsTrigger), 'ks-', LW, LW3);
        end
        hold off;
    end
end


% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
%% ----------------------------------------------- Plot Waveform Spectrograms -------------------------------------------------- 
% ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 
if bool.plotWaveformSpectrograms
    if ~ignorePlots
        figure(); ROW = 2; COL = 1;
        subplot(ROW,COL,1);
        sigPlot(waveform_pulse); legend('I','Q');
        FigText('IQ-plot','Samples','Amplitude',fontSize, fontSize);
        subplot(ROW,COL,2);
        pspectrum(waveform_pulse, SYS.fs, 'spectrogram','TimeResolution',1e-6);
        title('Spectrogram');

        figure(); ROW = 2; COL = 4;
        for iTX=1:SYS.txNum
            subplot(ROW,COL,iTX);
            plot(20.*log10(abs(xcorr(waveform(:,1), waveform(:,iTX)))));
        end
        FigText('Cross-correlation of waveforms','Samples','Cross-correlation [dB]',fontSize, fontSize);
        legend('CC_{1,1}','CC_{1,2}');
    end

    
    ROW = 2; COL = 4;
    if  strcmp(waveformMode,"TDM Alternating") ||  strcmp(waveformMode,"TDM Staggered") 
        ROW = 1; COL = 1; 
    elseif strcmp(waveformMode,"TDM UpDown") 
        COL = 1; 
    end
        
    figure('Name', 'Spectrograms for all TX channels');
    subplot('Position', [0.1 0.1, 0.8 0.8]);
    for iTX=1:SYS.waveformNum
        subplot(ROW,COL,iTX);
        pspectrum(waveform(:,iTX), SYS.fs, 'spectrogram','TimeResolution',1e-6);
        title(['TX channel #', num2str(iTX)], 'fontsize', fontSize);
    end
    sgtitle('Spectrograms for all TX channels');

end

end
