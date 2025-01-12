classdef helperAEWNormalizationLayer < nnet.layer.Layer
%helperAEWNormalizationLayer Wireless symbol normalization layer
% NormalizationLayer - A custom layer for L2 normalization
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
    Method {mustBeMember(Method,{'Energy','Average power'})} = 'Energy'
  end
  
  methods
    function layer = helperAEWNormalizationLayer(varargin)
      p = inputParser;
      addParameter(p,'Method','Energy')
      addParameter(p,'Name','normalization')
      addParameter(p,'Description','')
      
      parse(p,varargin{:})
      
      layer.Method = p.Results.Method;
      layer.Name = p.Results.Name;
      if isempty(p.Results.Description)
        layer.Description = p.Results.Method + " L2 normalization layer";
      else
        layer.Description = p.Results.Description;
      end
      
      layer.Type = 'Wireless Normalization';
    end
    
    function z = predict(layer, x)
      % Perform L2 normalization along the last dimension
      epsilon = 1e-6; % Small constant for numerical stability
      % Forward input data through the layer at prediction time and
      % output the result.
      %
      % Inputs:
      %         layer  - Layer to forward propagate through
      %         X      - Input samples
      % Outputs:
      %         Z      - Normalized samples
      %display(x)
      
      normFactor = sqrt(sum(x.^2, 1) + epsilon); % L2 norm along the last dimension
      z = x ./ normFactor; % Normalize input
      %display(z)
    end
    function dLdX = ...
        backward(layer, X, Z, dLdZ,memory)            
      
      dLdX = dLdZ;
    end

        % Function to save and load layer configurations
    function config = getConfig(layer)
       config = struct();
       config.Name = layer.Name;
       config.Description = layer.Description;
    end
  end
end