classdef StochasticChannelv3 < nnet.layer.Layer
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
       rollOff = 0.35;
       numTaps = 31;
       timeDelay = 0;
       r = 4; % Upsampling factor
       ts = 1; % Sampling period
  end
  
  methods
    function layer = StochasticChannelv3(varargin)
      p = inputParser;
      addParameter(p,'rollOff',0.35)
      addParameter(p,'numTaps',31)
      addParameter(p,'timeDelay',0)
      addParameter(p,'r',4)
      addParameter(p,'ts',1)
      addParameter(p,'Name','StochasticChannelv3')
      addParameter(p,'Description','')
      
      parse(p,varargin{:})

      layer.rollOff = p.Results.rollOff;
      layer.numTaps = p.Results.numTaps;
      layer.timeDelay = p.Results.timeDelay;
      layer.r = p.Results.r;
      layer.ts = p.Results.ts;
      layer.Name = p.Results.Name;

      if isempty(p.Results.Description)
        layer.Description = "Stochastic Channel layer";
      else
        layer.Description = p.Results.Description;
      end
      
    end
    
        % Upsampling
    function upsampled = upsampling(layer, input)
        % Reshape the input to a column vector
    
        com_reshape = reshape(input, [],1, size(input,4));
        %display(com_reshape)
        %com_reshape = double(extractdata(com_reshape));
                % Convert to double if necessary
        if ~isa(com_reshape, 'double')
            com_reshape = double(com_reshape);
        end
        
        % Create padding array
        padding = [0, layer.r - 1,0];

        % Pad the reshaped input
        upsampled = padarray(com_reshape, padding, 0, 'post');
        upsampled = permute(upsampled, [2, 1, 3]);
        % Flatten back to a 1D array
        upsampled = reshape(upsampled, [],1,size(input,4));
     
    end
        
    function upsampled = upsample_iq(layer, input)
        % Extract real and imaginary parts
        real_part = input(:, 1,:,:);  % Real part
        imag_part = input(:, 2,:,:);  % Imaginary part
    
        % Upsample real and imaginary parts
        real_up = layer.upsampling(real_part);
        imag_up = layer.upsampling(imag_part);
    
        % Stack real and imaginary parts back together
        upsampled = [real_up, imag_up];
    end
        % Root-Raised-Cosine (RRC) Filter
    function rrc = rrcFilter(layer)
        % Time vector calculation
        t = linspace(-layer.numTaps / 2, layer.numTaps / 2, layer.numTaps) - layer.timeOffset();
    
        % Initialize RRC array
        rrc = zeros(size(t));
    
        % Calculate RRC filter coefficients
        for i = 1:length(t)
            if t(i) == 0.0
                rrc(i) = (1.0 - layer.rollOff + 4 * layer.rollOff / pi) / layer.ts;
            elseif abs(t(i)) == layer.ts / (4 * layer.rollOff)
                rrc(i) = (layer.rollOff / (sqrt(2) * layer.ts)) * ...
                         ((1 + 2 / pi) * sin(pi / (4 * layer.rollOff)) + ...
                          (1 - 2 / pi) * cos(pi / (4 * layer.rollOff)));
            else
                rrc(i) = (sin(pi * (t(i) / layer.ts) * (1 - layer.rollOff)) + ...
                          4 * layer.rollOff * (t(i) / layer.ts) * cos(pi * (t(i) / layer.ts) * (1 + layer.rollOff))) / ...
                         (pi * t(i) * (1 - (4 * layer.rollOff * (t(i) / layer.ts))^2));
            end
        end
    
        % Normalize the filter
        rrc = rrc / sqrt(sum(rrc .^ 2));
    
        % Convert to single precision
        rrc = single(rrc);
    end
        
        % Phase Offset
    function phaseOffset = phaseOffset(layer)
        phaseOffset = rand() * 2 * pi; % Random uniform phase offset
    end
        
        % Upsample and Filter
     function filtered_signal = upsampleAndFilter(layer, signal)
        
        upsampled_signal = layer.upsample_iq(signal);
       
        rrc = layer.rrcFilter();
        %display(upsampled_signal)
    
        upsampled_signal = reshape(upsampled_signal, [1, size(upsampled_signal, 1), size(upsampled_signal, 2),size(upsampled_signal, 3)]);
        %display(upsampled_signal)
        rrc = reshape(rrc, [], 1, 1);  % Shape: (filter_length, 1, 1)
        
    
        padding_size = floor(layer.numTaps / 2);
        padded_real = padarray(upsampled_signal(:, :, 1, :), [0, padding_size,0], 0, 'both');
        padded_imag = padarray(upsampled_signal(:, :, 2,:), [0, padding_size,0], 0, 'both');
        upsampled_signal = cat(3, padded_real, padded_imag);
        %display(upsampled_signal)

        real_filtered = convn(upsampled_signal(:, :, 1,:), rrc, 'same');
        imag_filtered = convn(upsampled_signal(:, :, 2,:), rrc, 'same');
    
        phase_offset = layer.phaseOffset();
        cos_phase = cos(phase_offset);
        sin_phase = sin(phase_offset);
    
        real_filtered = real_filtered * cos_phase - imag_filtered * sin_phase;
        imag_filtered = imag_filtered * sin_phase + real_filtered * cos_phase;
    
        filtered_signal = cat(3, real_filtered, imag_filtered);
        %display(filtered_signal)
        filtered_signal = reshape(filtered_signal,1,[],size(filtered_signal,4));
        %filtered_signal = squeeze(filtered_signal);  % Remove the singleton dimension
        %display(filtered_signal)
        
     end
        
        % Time Offset
     function tOffset = timeOffset(layer, samplingTime)
        if nargin < 2
            samplingTime = 0.5e-6;
        end
        tOffset = rand() * 2 * samplingTime - samplingTime; % Random offset within range
     end
        
        % Forward pass
     function outputs = predict(layer, inputs)
        display(inputs)
        batchSize = size(inputs, 2);
        numFeatures = size(inputs, 1) / 2; % Assuming input has real and imaginary parts

            
        % Reshape input to separate real and imaginary parts
        inputs = reshape(inputs,numFeatures, 2, batchSize,[]);
        % Define a function to process each sample
        process_sample = @(sample) layer.upsampleAndFilter(sample);  % Process each sample
            
         % Apply the function to each sample in the batch
        output = arrayfun(@(i) process_sample(inputs(:, :, i,:)), 1:batchSize, 'UniformOutput', false);
        
        output = cat(1, output{:});  % Concatenate the output
        
        %output = cat(1,reshape(output(:,:,1)',batchSize,[]), reshape(output(:,:,2)',batchSize,[]));
        % Reshape back to original shape if necessary
        outputs = reshape(output, [], batchSize,size(inputs,4));
        display(outputs)
        
     end
%      function dLdX = backward(layer, X, Z, dLdZ, memory)
%         % Prevent backpropagation by setting gradients to zero
%         dLdX = zeros(size(X), 'like', X);  % Zero gradient for inputs
%         dLdParams = [];  % No trainable parameters
%      end
    function out = inverseUpsampleAndFilter(layer, dLdY)
    
        real_part = dLdY(1,:, :, :);
        imag_part = dLdY(2,:, :, :);
    
        
        %downsampling factor
        f = floor(layer.numTaps / 2);
        % Downsample the signal
        real_downsampled = real_part(:, f+1:size(real_part,2)-f, :, :);
        imag_downsampled = imag_part(:, f+1:size(real_part,2)-f, :, :);
        display(real_downsampled)
        
        real_downsampled = reshape(real_downsampled,4,[],size(real_downsampled,4));
        imag_downsampled = reshape(imag_downsampled,4,[],size(imag_downsampled,4));
        display(real_downsampled)

        real_downsampled = permute(real_downsampled,[2,1,3]);
        imag_downsampled = permute(imag_downsampled,[2,1,3]);
        display(real_downsampled)

        real_downsampled = reshape(real_downsampled, [], size(real_downsampled,3));
        imag_downsampled = reshape(imag_downsampled, [], size(imag_downsampled,3));
        display(real_downsampled)

        real = real_downsampled(1:size(real_downsampled,1)/layer.r,:);
        imag = imag_downsampled(1:size(real_downsampled,1)/layer.r,:);
        display(real)
        
        out = [real,imag];
        display(out)
        out = reshape(out,[],1,size(real,2));
        display(out)
    end


    function dLdX = backward(layer, ~, ~, dLdY, ~)
        % dLdY: Gradient of the loss with respect to the output of this layer
        % input: The original input to the forward method
        display(dLdY)
        % Step 1: Reshape dLdY to the expected output format (1x92x6400 in your case)
        dLdY = reshape(dLdY, 2, [],1, size(dLdY, 3));  % Adjust the size as needed
        display(dLdY)
        dLdX = layer.inverseUpsampleAndFilter(dLdY);  % Process each sample
        display(dLdX)

    
    
    end
     function config = getConfig(layer)
       config = struct();
       config.Name = layer.Name;
       config.Description = layer.Description;
    end

  end
end