function X = genCanCode(N, M, X0, threshhold_value)
% X = canmimo(N, M) or canmimo(N, M, X0), CAN MIMO
%   N: length of each transmit sequence
%   M: number of transmit sequences
%   X0: N-by-M, initialization sequence set

if nargin >= 3 && ~isempty(X0)
    X = X0;
else
    X = exp(1i * 2*pi * rand(N, M));
end

if nargin < 4 
   threshhold_value = 1e-3; % Suggested value 
end

XPrev = zeros(N, M);
iterDiff = norm(X - XPrev, 'fro');
Y = zeros(2*N, M);
V = zeros(2*N, M);

while (iterDiff > threshhold_value)
    %disp(iterDiff);
    XPrev = X;
    % step 1
    Y(1:N, :) = X;
    fftY = 1/sqrt(2*N) * fft(Y);
%     V = (1/sqrt(2)).*fftY./transpose(vecnorm(transpose(fftY)));
    V = (1/sqrt(2)).*fftY./vecnorm(fftY, 2, 2); % 2-norm across columns (transmitter)
     
    % step 2
    ifftV = sqrt(2*N) * ifft(V);
    X = exp(1i * angle(ifftV(1:N, 1:M)));
    % stop criterion
    iterDiff = norm(X - XPrev, 'fro');
end