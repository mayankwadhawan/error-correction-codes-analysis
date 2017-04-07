% Wireless Communication
% Mayank Wadhawan
% UFID - 59148122

%Clearing console
clc
clear
%Creating EbNo variable with value -2
EbNo= -2;
intrlvrIndices = randperm(256);
%Used to maintain error statistics
rateOfError = comm.ErrorRate('ComputationDelay',3);
%Creating Turbo Enoder
convEncoder = comm.TurboEncoder();
%Creating Turbo Decoder
viterbiDecoder = comm.TurboDecoder();
%Creating DPSK Modulator
dpskModulator = comm.BPSKModulator;
%Creating DPSK Demodulator
dpskDemodulator = comm.BPSKDemodulator('DecisionMethod','Log-likelihood ratio', ...
    'Variance',10^(0.6));
%Creating Additive White Gaussian Noise Channel
awgnChannel = comm.AWGNChannel('EbNo',EbNo);

%Checking for 19200 bits
for i = 1:300
  %creating random binary data in form of column vector
  dataToSend = randi([0 1], 64, 1);
  %Using Reed-Solomon Encoder to encode the data
  encoded = step(convEncoder, dataToSend);
  %Performing  DPSK Modulation
  afterModulation = step(dpskModulator, encoded);
  %Adding White Gaussian Noise to data
  dataReceived = step(awgnChannel, afterModulation);
  %Performing  DPSK Demodulation
  afterDemodulation = step(dpskDemodulator, dataReceived);
  %Using Reed-Solomon Decoder to decode the data
  decoded = step(viterbiDecoder, -afterDemodulation);
  %Fetching error statistics
  finaloutput = step(rateOfError, dataToSend, decoded);
end
%Printing the result
fprintf('BER = %f\nTotal Errors = %d \nNo. of Bits = %d\n',finaloutput(1), finaloutput(2), finaloutput(3))