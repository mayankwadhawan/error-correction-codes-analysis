% Wireless Communication
% Mayank Wadhawan
% UFID - 59148122

%Clearing console
clc;
clear;

%Used to maintain error statistics
rateOfError = comm.ErrorRate('ComputationDelay',3);
%Creating Convolutional Enoder
convEncoder = comm.ConvolutionalEncoder;
%Creating Viterbi Decoder
viterbiDecoder = comm.ViterbiDecoder('InputFormat','Hard');
%Creating DPSK Modulator
dpskModulator = comm.DPSKModulator('BitInput',true);
%Creating DPSK Demodulator
dpskDemodulator = comm.DPSKDemodulator('BitOutput',true);
%Creating Additive White Gaussian Noise Channel
awgnChannel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',10);

%Checking for 1200 bits
for i = 1:20
  %creating random binary data in form of column vector
  dataToSend = randi([0 1], 30, 1);
  %Using Reed-Solomon Encoder to encode the data
  encoded = step(convEncoder, dataToSend);
  %Performing  DPSK Modulation
  afterModulation = step(dpskModulator, encoded);
  %Adding White Gaussian Noise to data
  dataReceived = step(awgnChannel, afterModulation);
  %Performing  DPSK Demodulation
  afterDemodulation = step(dpskDemodulator, dataReceived);
  %Using Reed-Solomon Decoder to decode the data
  decoded = step(viterbiDecoder, afterDemodulation);
  %Fetching error statistics
  finaloutput = step(rateOfError, dataToSend, decoded);
end
%Printing the result
fprintf('BER = %f\nTotal Errors = %d \nNo. of Bits = %d\n',finaloutput(1), finaloutput(2), finaloutput(3))