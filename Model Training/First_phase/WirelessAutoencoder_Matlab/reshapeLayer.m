classdef reshapeLayer < nnet.layer.Layer
     properties
        w
        h
       
    end
    
    methods
        function layer =reshapeLayer(w,h,varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              addParameter(p,'w',w)
              addParameter(p,'h',h)
              addParameter(p,'Name','SlidingWindow')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
        
              layer.Name = p.Results.Name;
              layer.w = p.Results.w;
              layer.h = p.Results.h;
        
              if isempty(p.Results.Description)
                layer.Description = "Sliding Window";
              else
                layer.Description = p.Results.Description;
              end
      
        end
        
        function output = predict(layer, X)
            % Get the input dimension
            %display(X)
            output = reshape(X,layer.h,layer.w,[]);
            %display(output)

        end
        
        function gradients = backward(layer, X, Z, grad, ~)
            
            %display(grad)
    
            gradients = reshape(grad,size(X,1),size(X,2),size(X,3));
            %display(gradients)

        end
    end
end