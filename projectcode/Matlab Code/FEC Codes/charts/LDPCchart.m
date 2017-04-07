% Wireless Communication
% Mayank Wadhawan
% UFID - 59148122

%Clearing console
clc;
clear;
%Used to maintain error statistics
rateOfError = comm.ErrorRate('ComputationDelay',3);
%Creating LDPC Enoder
ldpcEncoder = comm.LDPCEncoder;
%Creating LDPC Decoder
ldpcDecoder = comm.LDPCDecoder;
%Creating Additive White Gaussian Noise Channel
awgnChannel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',0.78);
%Creating QPSK Modulator
pskModulator = comm.PSKModulator(4,'BitInput',true);
%Creating QPSK Demodulator
pskDemodulator =  comm.PSKDemodulator(4,'BitOutput',true,'DecisionMethod', ...
'Approximate log-likelihood ratio',...
            'VarianceSource','Input port');
snrValues = [0:0.1:0.8];
berValues = zeros(length(snrValues),1);
for k = 1:length(snrValues)
    awgnChannel.SNR = snrValues(k)
    finaloutput = zeros(1,3);
    noiseVar = 1/10^(snrValues(k)/10);
     while finaloutput(2) <= 250 && finaloutput(3) < 5e6 
        %creating random binary data in form of column vector
        dataToSend = logical(randi([0 1], 32400, 1));
        %Using LDPC Encoder to encode the data
        encoded = step(ldpcEncoder, dataToSend);
        %Performing  DPSK Modulation
        afterModulation = step(pskModulator, encoded);
        %Adding White Gaussian Noise to data
        dataReceived = step(awgnChannel, afterModulation);
        %Performing  DPSK Demodulation
        afterDemodulation = step(pskDemodulator, dataReceived,noiseVar);
        %Using LDPC Decoder to decode the data
        decoded = step(ldpcDecoder, afterDemodulation);
        %Fetching error statistics
        finaloutput = step(rateOfError, dataToSend, decoded);
    end
    berValues(k)=finaloutput(1);
    reset(rateOfError)
end

semilogy(snrValues,berValues,'-o')
grid
xlabel('SNR(dB)')
ylabel('BER')