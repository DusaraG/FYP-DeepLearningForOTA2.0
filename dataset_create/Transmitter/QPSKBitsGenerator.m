
classdef QPSKBitsGenerator < matlab.System
   
    properties (Nontunable)
        ScramblerBase;
        ScramblerPolynomial;
        ScramblerInitialConditions;
        NumberOfMessage;
        MessageLength;
        ModulationOrder;
        
        
    end
    
    properties (Access=private)
        pHeader
        pScrambler
        
    end
    
    properties (Access=private, Nontunable)
        pBarkerCode = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar Barker Code
    end
    
    methods
        function obj = QPSKBitsGenerator(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj, ~)
            % Generate unipolar Barker Code and duplicate it as header
            ubc = ((obj.pBarkerCode + 1) / 2)';
            temp = (repmat(ubc,1,2))';
            obj.pHeader = temp(:);
            
            % Initialize scrambler system object
            obj.pScrambler = comm.Scrambler( ...
                obj.ScramblerBase, ...
                obj.ScramblerPolynomial, ...
                obj.ScramblerInitialConditions);
            
        end
        
        function [y, msgBin] = stepImpl(obj,seqNum,frames)
            tag10 = de2bi([0;0;0;0]);
            % Generate message binaries from signal source.
            % msgBin = obj.pSigSrc();
            % data = randi([0 , obj.ModulationOrder-1],obj.NumberOfMessage,1);
            
            % bits = de2bi(data, log2(obj.ModulationOrder), 'left-msb')';
            msgBin = frames(:,seqNum-10);
            seqNUmbin = de2bi(seqNum, 2*6, 'left-msb')';
            msgBin=[seqNUmbin;tag10;msgBin];
            % Scramble the data
            % scrambledMsg = obj.pScrambler(msgBin);
            scrambledMsg = msgBin;
            % Append the scrambled bit sequence to the header
            y = [obj.pHeader ; scrambledMsg];
            
        end
        
        function resetImpl(obj)
            reset(obj.pScrambler);
            
        end
        
        function releaseImpl(obj)
            release(obj.pScrambler);
           
        end
        
        function N = getNumInputsImpl(~)
            N = 2;
        end
        
        function N = getNumOutputsImpl(~)
            N = 2;
        end
    end
end

