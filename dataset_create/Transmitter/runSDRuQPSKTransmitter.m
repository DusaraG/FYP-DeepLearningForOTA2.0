function underrun = runSDRuQPSKTransmitter(prmQPSKTransmitter,rx_out_complex)

    persistent hTx radio
    if isempty(hTx)
        % Initialize the components
        % Create and configure the transmitter System object
        hTx = QPSKTransmitter(...
            'UpsamplingFactor',             prmQPSKTransmitter.Interpolation, ...
            'RolloffFactor',                prmQPSKTransmitter.RolloffFactor, ...
            'RaisedCosineFilterSpan',       prmQPSKTransmitter.RaisedCosineFilterSpan, ...
            'MessageLength',                prmQPSKTransmitter.MessageLength, ...
            'NumberOfMessage',              prmQPSKTransmitter.NumberOfMessage, ...
            'ScramblerBase',                prmQPSKTransmitter.ScramblerBase, ...
            'ScramblerPolynomial',          prmQPSKTransmitter.ScramblerPolynomial, ...
            'ModulationOrder',              prmQPSKTransmitter.ModulationOrder,...
            'ScramblerInitialConditions',   prmQPSKTransmitter.ScramblerInitialConditions);

        % Create and configure the SDRu System object. 
        
          radio = comm.SDRuTransmitter(...
                    'Platform',             prmQPSKTransmitter.Platform, ...
                    'IPAddress',            prmQPSKTransmitter.Address, ...
                    'CenterFrequency',      prmQPSKTransmitter.USRPCenterFrequency, ...
                    'Gain',                 prmQPSKTransmitter.USRPGain, ...
                    'InterpolationFactor',  prmQPSKTransmitter.USRPInterpolationFactor);
          display(radio)  
    end    
    
    cleanupTx = onCleanup(@()release(hTx));
    cleanupRadio = onCleanup(@()release(radio));

    currentTime = 0;
    underrun = uint32(0);

    moddata=[];
    txdata=[];
    seqnumqpsk=1;
    seqnumdata=11;
    pTransmitterFilter = comm.RaisedCosineTransmitFilter( ...
                'RolloffFactor',                prmQPSKTransmitter.RolloffFactor, ...
                'FilterSpanInSymbols',          prmQPSKTransmitter.RaisedCosineFilterSpan, ...
                'OutputSamplesPerSymbol',       prmQPSKTransmitter.Interpolation);
    %Transmission Process
    disp("started")
    n=1;
    r=10000;            
    rx_out_complex = rx_out_complex';
    for i = 1:n 
        for j = 1:r
            tunderrun =radio(pTransmitterFilter(rx_out_complex(:,i)));
            underrun = underrun + tunderrun;
        end
    end

    % while currentTime < prmQPSKTransmitter.StopTime
    %     % Bit generation, modulation and transmission filtering
    % 
    % 
    % 
    %     [modulatedData,data] = hTx(seqnumdata,frames);
    %     seqnumdata=seqnumdata+1;
    %     if (rem(seqnumdata-11,100))==0
    %         seqnumqpsk=1;
    %     end
    %     moddata=[moddata,modulatedData];
    %     txdata=[txdata,data];
    % 
    % 
    %     % Data transmission
    %     tunderrun = radio(double(data));
    % 
    %     underrun = underrun + tunderrun;
    %     % Update simulation time
    %     currentTime=currentTime+prmQPSKTransmitter.USRPFrameTime;
    %     if seqnumdata==numFrames+10+1
    %         disp("r3ki3g broke while loop");
    %         break;
    %     end
    % 
    % end
    % 
    % % save('mesdata.mat','mesdata');
    % save('txdata.mat','txdata');
    % save('moddata.mat','moddata');
    % 
    % % moddata = reshape(moddata,[],1);
    % % scatterplot(moddata);

end