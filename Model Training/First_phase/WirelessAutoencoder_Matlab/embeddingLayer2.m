classdef embeddingLayer2 < nnet.layer.Layer
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
    properties (Learnable)
            % Learnable parameters
            EmbeddingMatrix
    end

    properties
            
            inputDim;
            outputDim;
    end

  
  methods
    function layer = embeddingLayer2(inputDim, outputDim,varargin)
      p = inputParser;
      addParameter(p,'inputDim',inputDim)
      addParameter(p,'outputDim',outputDim)
      addParameter(p,'Name','embeddingLayer 2')
      addParameter(p,'Description','')
      
      parse(p,varargin{:})

      layer.inputDim = p.Results.inputDim;
      layer.outputDim = p.Results.outputDim;
      layer.Name = p.Results.Name;
      layer.EmbeddingMatrix = randn(inputDim, outputDim);
      

      if isempty(p.Results.Description)
        layer.Description = "embedding Layer 2";
      else
        layer.Description = p.Results.Description;
      end
      
    end
    
    function Z = predict(layer, X)
            % Forward function: lookup embeddings for each input
        %display("Embeding")
        
        Z = layer.EmbeddingMatrix(X + 1, :)'; % MATLAB indexing starts from 1
     
    end
        
    function [dLdX, dLdW] = backward(layer, X,~, dLdZ,~)
        % Backward function: compute the gradient of the loss with respect to the input and the learnable parameters
        % dLdZ is the gradient of the loss with respect to the output Z
        % dLdX is the gradient of the loss with respect to the input X
        % dLdW is the gradient of the loss with respect to the EmbeddingMatrix

        % Initialize the gradient matrices

        
        dLdX = single(zeros(size(X)));
        
        dLdW = single(zeros(size(layer.EmbeddingMatrix)));

        % Compute the gradient for each input
        for i = 1:size(X, 2)
            dLdX(i) = sum(dLdZ(:, i)' .* layer.EmbeddingMatrix(X(i) + 1, :), 2);
            dLdW(X(i) + 1, :) = dLdW(X(i) + 1, :) + dLdZ(:, i)';
        end
        
    end


     function config = getConfig(layer)
       config = struct();
       config.inputDim = layer.inputDim;
       config.outputDim = layer.outputDim;
       config.Name = layer.Name;
       config.Description = layer.Description;
    end

  end
end