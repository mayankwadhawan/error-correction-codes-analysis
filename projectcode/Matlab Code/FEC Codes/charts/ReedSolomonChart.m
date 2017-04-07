% Wireless Communication
% Mayank Wadhawan
% UFID - 59148122

%Clearing console
clc
clear;
%Used to maintain error statistics
rateOfError = comm.ErrorRate('ComputationDelay',3);
%Creating Reed-Solomon Enoder
rsEncoder = comm.RSEncoder;
%Creating Reed-Solomon Decoder
rsDecoder = comm.RSDecoder;
%Creating DPSK Modulator
dpskModulator = comm.DPSKModulator('BitInput',false);
%Creating DPSK Demodulator
dpskDemodulator = comm.DPSKDemodulator('BitOutput',false);
%Creating Additive White Gaussian Noise Channel
awgnChannel = comm.AWGNChannel('NoiseMethod' , 'Signal to noise ratio (SNR)' , 'SNR',10);
snrValues = [0:1:15];
berValues = zeros(length(snrValues),1);
for k = 1:length(snrValues)
    awgnChannel.SNR = snrValues(k)
    finaloutput = zeros(1,3);
     while finaloutput(2) <= 100000 && finaloutput(3) < 5e6 
  %creating random binary data in form of column vector
  dataToSend = randi([0 7], 32400, 1);
  %Using Reed-Solomon Encoder to encode the data
  encoded = step(rsEncoder, dataToSend);
  %Performing  DPSK Modulation
  afterModulation = step(dpskModulator, encoded);
  %Adding White Gaussian Noise to data
  dataReceived = step(awgnChannel, afterModulation);
  %Performing  DPSK Demodulation
  afterDemodulation = step(dpskDemodulator, dataReceived);
  %Using Reed-Solomon Decoder to decode the data
  decoded = step(rsDecoder, afterDemodulation);
  %Fetching error statistics
  finaloutput = step(rateOfError, dataToSend, decoded);
     end
      berValues(k)=finaloutput(1);
    reset(rateOfError)
end
%Printing the result
semilogy(snrValues,berValues,'-o')
grid
xlabel('SNR(dB)')
ylabel('BER')