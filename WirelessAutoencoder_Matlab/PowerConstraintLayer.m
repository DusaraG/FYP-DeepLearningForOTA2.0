classdef PowerConstraintLayer < nnet.layer.Layer
    % PowerConstraintLayer - A custom layer to constrain the power of inputs
    
    methods
        % Constructor
        function layer = PowerConstraintLayer(varargin)
            p = inputParser;
            addParameter(p,'Name','PowerConstraintLayer')
            addParameter(p,'Description','')

            parse(p,varargin{:})

            layer.Name = p.Results.Name;
            if isempty(p.Results.Description)
              layer.Description = "Power Constraint Layer";
            else
              layer.Description = p.Results.Description;
            end
            
        end

        % Forward pass
        function outputs = predict(layer, x)

            [h, ~, ~] = size(x); % h = height, w = width, c = number of channels
            % Split real and imaginary parts
            
            real_parts = x(1:h/2,:, :); % First 4 elements
            imag_parts = x(h/2+1:end,:, :); % Last 4 elements
            %disp(x);

            % Compute magnitudes
            magnitudes = sqrt(real_parts.^2 + imag_parts.^2);
            %display(magnitudes)

            % Compute scale factor
            % If magnitudes <= 1, scale factor is 1; otherwise, use magnitudes
            scale_factor = ones(size(magnitudes));
            scale_factor(magnitudes > 1) = magnitudes(magnitudes > 1);

            % Concatenate scale factor for both real and imaginary parts
            scale_factor = cat(1, scale_factor, scale_factor);
     
            % Scale the inputs
            outputs = x ./ scale_factor;
            %display(outputs)
            
        end

        % Function to save and load layer configurations
        function config = getConfig(layer)
            config = struct();
            config.Name = layer.Name;
            config.Description = layer.Description;
        end
        function dLdX = ...
            backward(layer, X, Z, dLdZ,memory)
          % (Optional) Backward propagate the derivative of the loss
          % function through the layer.
          %
          % Inputs:
          %         layer             - Layer to backward propagate through
          %         X1, ..., Xn       - Input data
          %         Z1, ..., Zm       - Outputs of layer forward function
          %         dLdZ1, ..., dLdZm - Gradients propagated from the next layers
          %         memory            - Memory value from forward function
          % Outputs:
          %         dLdX1, ..., dLdXn - Derivatives of the loss with respect to the
          %                             inputs
          %         dLdW1, ..., dLdWk - Derivatives of the loss with respect to each
          %                             learnable parameter
          
          dLdX = dLdZ;
       end
    end
end
