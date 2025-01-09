classdef (StrictDefaults)QPSKTransmitter < matlab.System  

    
    properties (Nontunable)
        UpsamplingFactor;
        ScramblerBase ;
        ScramblerPolynomial ;
        ScramblerInitialConditions;
        RolloffFactor;
        RaisedCosineFilterSpan;
        NumberOfMessage;
        MessageLength;
        txnet;
        ModulationOrder;
    end
    
    properties (Access=private)
        pBitGenerator
        pTransmitterFilter
        
        pHeader = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar barker-code
    end
    
    methods
        function obj = QPSKTransmitter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj)
            obj.pBitGenerator = QPSKBitsGenerator( ...
                'NumberOfMessage',              obj.NumberOfMessage, ...
                'MessageLength',                obj.MessageLength, ...
                'ScramblerBase',                obj.ScramblerBase, ...
                'ScramblerPolynomial',          obj.ScramblerPolynomial, ...
                'ModulationOrder',              obj.ModulationOrder,...
                'ScramblerInitialConditions',   obj.ScramblerInitialConditions);

            obj.pTransmitterFilter = comm.RaisedCosineTransmitFilter( ...
                'RolloffFactor',                obj.RolloffFactor, ...
                'FilterSpanInSymbols',          obj.RaisedCosineFilterSpan, ...
                'OutputSamplesPerSymbol',       obj.UpsamplingFactor);
        end

        function [modulatedData,transmittedSignal] = stepImpl(obj,seqnum,frames) 
            [transmittedBin, ~] = obj.pBitGenerator(seqnum,frames);                 % Generates the data to be transmitted
            modulatedDataHeader = pskmod(transmittedBin(1:42),4,pi/4,InputType="bit",OutputDataType="double");        % Modulates the bits into QPSK symbols  
            %%%%%
            % modulatedDataHeader = qammod(transmittedBin(1:42),4,InputType="bit",UnitAveragePower=true);%,UnitAveragePower=true


            % modulatedData = pskmod(transmittedBin(43:end),4,pi/4,InputType="bit",OutputDataType="double");%,UnitAveragePower=true
            % modulatedData = qammod(transmittedBin(43:end),16,InputType="bit");%,UnitAveragePower=true

            modulatedData = helperAEWEncode(transmittedBin(43:end),obj.txnet);
            modulatedData = [modulatedDataHeader;modulatedData];
           
            transmittedSignal = obj.pTransmitterFilter(modulatedData); % Square root Raised Cosine Transmit Filter
        end
        
        function resetImpl(obj)
            reset(obj.pBitGenerator);
            reset(obj.pTransmitterFilter);
        end
        
        function releaseImpl(obj)
            release(obj.pBitGenerator);
            release(obj.pTransmitterFilter);
        end
        
        function N = getNumInputsImpl(~)
            N = 2;
        end
    end
end

