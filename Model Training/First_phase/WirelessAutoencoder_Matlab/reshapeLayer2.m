classdef reshapeLayer2 < nnet.layer.Layer
    
    methods
        function layer =reshapeLayer2(varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              
              addParameter(p,'Name','output_reshaper')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
        
              layer.Name = p.Results.Name;
 
        
              if isempty(p.Results.Description)
                layer.Description = "output reshaper";
              else
                layer.Description = p.Results.Description;
              end
      
        end
        
        function output = predict(layer, X)
            % Get the input dimension
            %display(X)
            output = reshape(X,[],size(X,3));
            %display(output)

        end
        
        function gradients = backward(layer, X, Z, grad, ~)
            
            %display(grad)
    
            gradients = reshape(grad,size(X));
            %display(gradients)

        end
    end
end