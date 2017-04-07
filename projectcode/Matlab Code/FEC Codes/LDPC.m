% Wireless Communication
% Mayank Wadhawan
% UFID - 59148122

%Clearing console
clc
clear
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
pskDemodulator =  comm.PSKDemodulator(4, 'BitOutput',true);


%Checking for 486000 bits
for i = 1:15 
  %creating random binary data in form of column vector
  dataToSend = logical(randi([0 1], 32400, 1));
  %Using LDPC Encoder to encode the data
  encoded = step(ldpcEncoder, dataToSend);
  %Performing  DPSK Modulation
  afterModulation = step(pskModulator, encoded);
  %Adding White Gaussian Noise to data
  dataReceived = step(awgnChannel, afterModulation);
  %Performing  DPSK Demodulation
  afterDemodulation = step(pskDemodulator, dataReceived);
  %Using LDPC Decoder to decode the data
  decoded = step(ldpcDecoder, afterDemodulation);
  %Fetching error statistics
  finaloutput = step(rateOfError, dataToSend, decoded);
end
%Printing the result
fprintf('BER = %f\nTotal Errors = %d \nNo. of Bits = %d\n',finaloutput(1), finaloutput(2), finaloutput(3))