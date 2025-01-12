classdef pe_2Layer < nnet.layer.Layer

    methods
        function layer = pe_2Layer(varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              addParameter(p,'Name','pe_2')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
              layer.Name = p.Results.Name;
        
              if isempty(p.Results.Description)
                layer.Description = "phase estimator 2nd layer";
              else
                layer.Description = p.Results.Description;
              end
      
            
           
        end
        
        function output = predict(layer, X)
          


            %display(X)
            hReal = X(1, :,:);
            hImag = X(2, :,:);
            
            
            % Concatenate the outputs
            output = cat(1, hReal, hImag);
            %display(output)
            %output = dlarray(extractdata(output));
            %display(output)

        end
        function dLdX = backward(layer, X, Z, dLdZ,~)
%             % Backward pass for the custom flatten layer
            dLdX = dLdZ; % Reshape the gradients back to the input shape
        end

    end
end
