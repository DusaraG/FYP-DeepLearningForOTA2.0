classdef connectionLayer < nnet.layer.Layer
    properties
        InputSize = 58;
    end

    methods
        function layer = connectionLayer(varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              addParameter(p,'Name','connectionLayer')
              addParameter(p,'Description','')
              addParameter(p,'InputSize','InputSize')
              
              parse(p,varargin{:})
              layer.Name = p.Results.Name;
              layer.InputSize = p.Results.InputSize;
        
              if isempty(p.Results.Description)
                layer.Description = "connectionLayer";
              else
                layer.Description = p.Results.Description;
              end
      
            
           
        end
        
        function output = predict(layer, X)
           
            output = X;

        end
        function dLdX = backward(layer, X, Z, dLdZ,~)
%             % Backward pass for the custom flatten layer
            dLdX = dLdZ; % Reshape the gradients back to the input shape
        end

    end
end
