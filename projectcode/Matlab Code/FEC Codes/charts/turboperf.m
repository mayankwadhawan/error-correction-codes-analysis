%Used to maintain error statistics
rateOfError = comm.ErrorRate;
%Creating Turbo Enoder
turboEncoder = comm.TurboEncoder('InterleaverIndicesSource','Input port');
%Creating Turbo Decoder
turbodec = comm.TurboDecoder('NumIterations',4,'InterleaverIndicesSource','Input port');
%creating values for EbNo
ebnoValues = (-5:-1);
%initializing BER
bitErrorRate = zeros(size(ebnoValues));
%Creating Additive White Gaussian Noise Channel
awgnChannel = comm.AWGNChannel('EbNo',ebnoValues,'BitsPerSymbol',log2(16));
%Creating 16-QAM modulator
modulator = comm.RectangularQAMModulator('NormalizationMethod','Average power','BitInput',true,'ModulationOrder', 16);
%Creating 16-QAM demodulator
demodulator = comm.RectangularQAMDemodulator('BitOutput',true,'NormalizationMethod',...
                            'Average power','DecisionMethod','Log-likelihood ratio',...
                            'VarianceSource','Input port',...
                            'ModulationOrder',16);
%Setting length of Frame
lengthOfFrame = 500;
%looping for each value of EbN0
for i = 1:length(ebnoValues)
    %temp variabe for storing BER values
    dataForOutput = zeros(1,3);
    %calculating noise
    noise = 10^(-ebnoValues(i)/10)*(1/log2(16));
    %Setting EbN0 in awgn channel
    awgnChannel.EbNo = ebnoValues(i);
    %looping till certaing errors or data
    while dataForOutput(2) < 85 && dataForOutput(3) < 1e7
        %creating random data
        dataToSend = randi([0 1],lengthOfFrame,1);
        %creating random interleaving indices
        interleaverIndices = randperm(lengthOfFrame);
        %encoding
        encoded = step(turboEncoder,dataToSend,interleaverIndices);
        %modulating
        afterModulation = step(modulator,encoded);
        %sending through awgn channel
        dataReceined = step(awgnChannel,afterModulation);
        %demodulating
        afterDemodulation = step(demodulator,dataReceined,noise);
        %decoding
        decoded = step(turbodec,-afterDemodulation,interleaverIndices);
        %comparing results
        dataForOutput = step(rateOfError,dataToSend,decoded);
    end
    %storing BER
    bitErrorRate(i) = dataForOutput(1);
    %resetting rateOfError
    reset(rateOfError)
end
%used for creating charts
semilogy(ebnoValues,bitErrorRate,'-o')
grid
%setting xlabel
xlabel('Eb/No (dB)')
%setting y label
ylabel('BER')
%finding uncoded signal
uncodedBER = berawgn(ebnoValues,'qam',16);
hold on
%plotting values
semilogy(ebnoValues,uncodedBER)
%setting legends
legend('Turbocode','Uncoded','location','sw')