function code_sequence = genGoldCode(nCodes,nBits) 
%goldcode outputs a number of gold codes with a specified length 
% n is the number of registers 
% N is number of sequences and maximum sequence length
% Table of valid number of registers and their preferred values: 
% n     N       Preferred Polynomial[1]	Preferred Polynomial[2]
% 5     31      [5 2 0]                 [5 4 3 2 0]
% 6     63      [6 1 0]                 [6 5 2 1 0]
% 7     127     [7 3 0]                 [7 3 2 1 0]
% 9     511     [9 4 0]                 [9 6 4 3 0]
% 10	1023	[10 3 0]                [10 8 3 2 0]
% 11	2047	[11 2 0]                [11 8 5 2 0]
% Made myself:
% 12	4095	[12 7 6 4 0];       [12 9 8 5 4 3 0];

%Illustration of the maximum number of samples per sequence
illustration_max_N = 0; 

% Illustration of the cross correlation between the first code and all the
% others 
illustration_cross_corr = 0;

% Determine number of shift registers
% bit_length = 1/Bandwidth; % One bit is the same as one pulse
if nBits < 32 
    nRegisters = 5; 
elseif nBits < 64 
    nRegisters = 6; 
elseif nBits < 128 
    nRegisters = 7; 
elseif nBits < 512
    nRegisters = 9;
elseif nBits < 1024
    nRegisters = 10;
elseif nBits < 2048
    nRegisters = 11;
else
    nRegisters = 12; 
end

% Check that the number of registers is correct 
if isempty(find(nRegisters == [5 6 7 9 10 11 12],1))
    error('Number of shift registers not valid') 
end 

% The maximum sequence length 
N = 2^nRegisters-1; 

if nBits > N
    error('The sequence length has exceeded the maximum sequence length') 
end

% Define the object to compute the goldcodes 
if nRegisters == 5
%     shift = 0; 
    goldseq = comm.GoldSequence('FirstPolynomial',[5 2 0],...
        'SecondPolynomial',[5 4 3 2 0],...
        'FirstInitialConditions',[0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);
    
elseif nRegisters == 6
    goldseq = comm.GoldSequence('FirstPolynomial',[6 1 0],...
        'SecondPolynomial',[6 5 2 1 0],...
        'FirstInitialConditions',[0 0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);   
        
elseif nRegisters == 7
    goldseq = comm.GoldSequence('FirstPolynomial',[7 3 0],...
        'SecondPolynomial',[7 3 2 1 0],...
        'FirstInitialConditions',[0 0 0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);                          
    
elseif nRegisters == 9
    goldseq = comm.GoldSequence('FirstPolynomial',[9 4 0],...
        'SecondPolynomial',[9 6 4 3 0],...
        'FirstInitialConditions',[0 0 0 0 0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);
                                          
elseif nRegisters == 10
    goldseq = comm.GoldSequence('FirstPolynomial',[10 3 0],...
        'SecondPolynomial',[10 8 3 2 0],...
        'FirstInitialConditions',[0 0 0 0 0 0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 0 0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);
    
elseif nRegisters == 11
    goldseq = comm.GoldSequence('FirstPolynomial',[11 2 0],...
        'SecondPolynomial',[11 8 5 2 0],...
        'FirstInitialConditions',[0 0 0 0 0 0 0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 0 0 0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);
    
elseif nRegisters == 12
    goldseq = comm.GoldSequence('FirstPolynomial',[12 7 6 4 0],...
        'SecondPolynomial',[12 9 8 5 4 3 0],...
        'FirstInitialConditions',[0 0 0 0 0 0 0 0 0 0 0 1],...
        'SecondInitialConditions',[0 0 0 0 0 0 0 0 0 0 0 1],...
        'Index',-2,'SamplesPerFrame',nBits);
end

% Compute the different gold codes 
code_sequence = zeros(nBits,nCodes); 
for i = 1:nCodes
    release(goldseq)
    goldseq.Index = i-3; % Index starts at -2 

    code_sequence(:,i) = goldseq();

%         % Change 0's to -1 
% codes = 1.*exp(1i*code_sequence*pi);
% tmp = zeros(4095,8); 
% for ii = 1:nCodes 
%     tmp(:,ii) = conv(codes(:,ii),(codes(end:-1:1,1))','same');
% end
% % figure; plot(mag2db(abs(tmp)))
% figure; plot(mag2db(abs(tmp./max(max(tmp))))); ylim([-50 0]);

%         code_sequence((code_sequence(:,i)==0),i) = code_sequence((code_sequence(:,i)==0),i)-1; 
end
   
    
if illustration_max_N
    release(goldseq)
    goldseq.SamplesPerFrame = 2*N; 
    x = goldseq();

    x = x*0.67; 
    figure
    plot(x(1:N),'Linewidth',1.2)
    hold on 
    plot(x(N+1:end)+1,'Linewidth',1.2)
    ylim([-1/3 2])
    legend('First N samples','Second N samples')
end


if illustration_cross_corr        
    release(goldseq)
    goldseq.SamplesPerFrame = N;
    
    x = zeros(N,N+1); 
    x2 = zeros(N*2-1,N+1);
    for i = 1:N+1
        release(goldseq)
        goldseq.Index = i-3; 

        x(:,i) = goldseq();
        
        % Change 0's to -1 
        x((x(:,i)==0),i) = x((x(:,i)==0),i)-1; 
    end
    
    % Cross correlation
    sequence_test = 6;
    for i = 1:N+1 
        x2(:,i) = xcorr(x(:,sequence_test),x(:,i));
    end

    %Normalized manitude
    x3 = mag2db(x2./max(max(x2))); 
   
%     %Plotting
%     figure
%     plot(-(N-1):(N-1),x2)
%     legend('Correct correlation') 
%     xlabel('Delay [samples]') 
%     ylabel('Cross correlation magnitude') %maximum is equal to N 
%     axis tight
    
    %Plotting
    figure
    plot(-(N-1):(N-1),x3)
    legend('Correct correlation') 
    xlabel('Delay [samples]') 
    ylabel('Cross correlation [dB]') %maximum is equal to N 
    ylim([-40 0]) 
    
    %Define Hamming distance
    ii = sort(reshape(abs(x2),(N*2-1)*(N+1),1));
    side_lobe_peak = ii(end-1);
    Hamming_distance = N-side_lobe_peak; 
    
    fprintf('Hamming distance = %d \n',Hamming_distance)
end

end
