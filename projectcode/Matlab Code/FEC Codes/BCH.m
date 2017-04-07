% Wireless Communication
% Mayank Wadhawan
% UFID - 59148122

%Clearing console
clc
clear

%Used to maintain error statistics
rateOfError = comm.ErrorRate('ComputationDelay',3);
%Creating BCH Enoder
bchEncoder = comm.BCHEncoder;
%Creating BCH Decoder
bchDecoder = comm.BCHDecoder;
%Creating DPSK Modulator
dpskModulator = comm.DPSKModulator('BitInput',true);
%Creating DPSK Demodulator
dpskDemodulator = comm.DPSKDemodulator('BitOutput',true);
%Creating Additive White Gaussian Noise Channel
awgnChannel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',8);

%Checking for 1600 bits
for i = 1:40
  %creating random binary data in form of column vector
  dataToSend = randi([0 1], 40, 1);
  %Using BCH Encoder to encode the data
  encoded = step(bchEncoder, dataToSend);
  %Performing  DPSK Modulation
  afterModulation = step(dpskModulator, encoded);
  %Adding White Gaussian Noise to data
  dataReceived = step(awgnChannel, afterModulation);
  %Performing  DPSK Demodulation
  afterDemodulation = step(dpskDemodulator, dataReceived);
  %Using BCH Decoder to decode the data
  decoded = step(bchDecoder, afterDemodulation);
  %Fetching error statistics
  finaloutput = step(rateOfError, dataToSend, decoded);
end
%Printing the result
fprintf('BER = %f\nTotal Errors = %d \nNo. of Bits = %d\n',finaloutput(1), finaloutput(2), finaloutput(3))