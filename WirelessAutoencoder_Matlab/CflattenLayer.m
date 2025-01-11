classdef CflattenLayer < nnet.layer.Layer
    methods
        function layer = CflattenLayer(varargin)
            % Constructor for the custom flatten layer
              p = inputParser;
              addParameter(p,'Name','SDRNN')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
        
              layer.Name = p.Results.Name;
        
              if isempty(p.Results.Description)
                layer.Description = "Custom flatten layer";
              else
                layer.Description = p.Results.Description;
              end
      
        end
        
        function Z = predict(layer, X)
            % Flatten the input in the forward pass
            display(X)
            Z = reshape(X, [] ,size(X,3)); % Reshape to 2D matrix: [batchSize, flattenedSize]
            display(Z)
        end
        
        function dLdX = backward(layer, X, Z, dLdZ,~)
            % Backward pass for the custom flatten layer
            dLdX = reshape(dLdZ, size(X)); % Reshape the gradients back to the input shape
        end
    end
end