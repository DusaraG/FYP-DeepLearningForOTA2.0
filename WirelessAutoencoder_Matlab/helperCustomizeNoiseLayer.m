classdef helperCustomizeNoiseLayer < nnet.layer.Layer
%helperAEWNormalizationLayer Wireless symbol normalization layer
%   layer = helperAEWNormalizationLayer creates a wireless symbol
%   normalization layer. 
%
%   layer = helperAEWNormalizationLayer('PARAM1', VAL1, 'PARAM2', VAL2, ...)
%   specifies optional parameter name/value pairs for creating the layer:
%
%       'Name'   - A name for the layer. The default is ''.
%       'Method' - Normalization method as one of 'Energy' and 
%                  'Average power'. The default is 'Energy'.
%
%   Example:
%       % Create a normalization layer for energy normalization.
%
%       layer = helperAEWNormalizationLayer('Method','Energy');
%
%   See also AutoencoderForWirelessCommunicationsExample, helperAEWEncode,
%   helperAEWDecode, helperAEWAWGNLayer.

%   Copyright 2020 The MathWorks, Inc.

  properties
    %NoiseMethod {mustBeMember(NoiseMethod,{'EbNo','EsNo','SNR'})} = 'EbNo' 
    EbNo = 15
    mean = 0
    stddev = 10^(-1.0*15)
  end
  
  methods
    function layer = helperCustomizeNoiseLayer(varargin)
      p = inputParser;
      %addParameter(p,'NoiseMethod','EbNo')
      addParameter(p,'EbNo',15)
      addParameter(p,'mean',0)
      addParameter(p,'stddev',10^(-1.0*15))
      addParameter(p,'Name','CustomNoise')
      addParameter(p,'Description','')
      
      parse(p,varargin{:})
      %layer.NoiseMethod = p.Results.NoiseMethod;
      layer.EbNo = p.Results.EbNo;
      layer.stddev = p.Results.stddev;
      layer.mean = p.Results.mean;
      layer.Name = p.Results.Name;
      if isempty(p.Results.Description)
        layer.Description = "costom noise layer";
      else
        layer.Description = p.Results.Description;
      end
      
      layer.Type = 'costom noise';
    end
    
    function z = predict(layer, x)
            % Forward pass: Adds Gaussian noise to the input
            % X: Input data
            % Z: Output data with added noise
            

            % Generate Gaussian noise with specified mean and standard deviation
            noise = layer.mean + layer.stddev * randn(size(x));

            % Add noise to the input
            z = x + noise;
            
    end
    function dLdX = ...
        backward(layer, X, Z, dLdZ,memory)

      dLdX = dLdZ;
    end
  end
end