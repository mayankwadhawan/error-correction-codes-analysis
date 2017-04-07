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
awgnChannel = comm.AWGNChannel('SNR',10,'NoiseMethod','Signal to noise ratio (SNR)');

snrValues = [0:1:10];  
berValues = zeros(length(snrValues),1);
for k = 1:length(snrValues)
    awgnChannel.SNR = snrValues(k)
    finaloutput = zeros(1,3);
     while finaloutput(2) <= 1000 && finaloutput(3) < 5e6 
  %creating random binary data in form of column vector
  dataToSend = randi([0 1], 32400, 1);
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
      berValues(k)=finaloutput(1);
    reset(rateOfError)
end
%Printing the result
semilogy(snrValues,berValues,'-o')
grid
xlabel('SNR(dB)')
ylabel('BER')