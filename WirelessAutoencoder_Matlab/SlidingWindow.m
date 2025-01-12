classdef SlidingWindow < nnet.layer.Layer
    properties
        window_size;
    end
    
    methods
        function layer =SlidingWindow(window_size,varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              addParameter(p,'window_size',window_size)
              addParameter(p,'Name','SlidingWindow')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
        
              layer.window_size = p.Results.window_size;
              layer.Name = p.Results.Name;
        
              if isempty(p.Results.Description)
                layer.Description = "Sliding Window";
              else
                layer.Description = p.Results.Description;
              end
      
        end
        
        function output = predict(layer, X)
            % Get the input dimension
            [rows, time, batch_size] = size(X);
            pad_size = floor(layer.window_size / 2);
            padded_matrix = padarray(X, [pad_size 0 0], 0, 'both');
            %display(padded_matrix)

            % Initialize the matrix to store sliding windows
            window_slices = cell(1,layer.window_size);
            
            % Generate sliding windows (slices) and store them in a cell array
            for i = 1:layer.window_size
                window_slices{i} = padded_matrix(i:i + rows - 1, :, :);
            end
            
            % Concatenate the windows along the depth dimension
            output = cat(1, window_slices{:});
            
            %display(output)

        end
        
        function gradients = backward(layer, X, Z, grad, ~)
            % Forward pass
            %display(grad)
            padsize = floor(layer.window_size / 2);
            gradients = grad(padsize:padsize+size(X,1)-1,:,:);
            %display(gradients)

        end
        % Get configuration for serialization
        function config = get_config(layer)
            config.window_size = layer.window_size;
        end

    end
end