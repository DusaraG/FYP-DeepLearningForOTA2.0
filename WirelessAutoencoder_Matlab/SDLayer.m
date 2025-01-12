classdef SDLayer < nnet.layer.Layer
    properties
        l = 6;
        n = 4;
        r = 4;
       
        fe
        pe
        oe
    end
    
    methods
        function layer = SDLayer(varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              addParameter(p,'l',6)
              addParameter(p,'n',4)
              addParameter(p,'r',4)
             
              addParameter(p,'Name','SD_mini_Layer')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
        
              layer.l = p.Results.l;
              layer.n = p.Results.n;
              layer.r = p.Results.r;
              
              layer.Name = p.Results.Name;
        
              if isempty(p.Results.Description)
                layer.Description = "SD mini layer";
              else
                layer.Description = p.Results.Description;
              end
      
            
           
        end
        
        function output = predict(layer, X)
            % Get the input dimension
    
            %display(X)
            mini_inputs = layer.mini_slicer(X);
            output = mini_inputs;
            %display(output)
            %output = dlarray(extractdata(output));
            %display(output)

        end

         % Mini Slicer Method
        function output = mini_slicer(layer, inputs)
            % Calculate slicing index based on layer properties
            N_msg = layer.r * layer.n;
            l1 = 30 + (layer.l) * 2 * N_msg;
            l2 = 30 + (layer.l + 1) * 2 * N_msg;
            
            % Slice the inputs based on computed indices
            output = inputs(l1:l2-1,:,:); % Adjust indices accordingly
            
        end
%         function [dLdX] = backward(layer, X,~, dLdY,~) 
%             % Get the input dimension 
%             inDim = size(X, 1); 
%             
%             % Calculate slicing index based on layer properties 
%             N_msg = layer.r * layer.n; 
%             l1 = 30 + (layer.l) * 2 * N_msg; 
%             l2 = 30 + (layer.l + 1) * 2 * N_msg; 
%             % Initialize the gradient with respect to the input 
%             dLdX = zeros(size(X), 'like', X); 
%             % Assign the gradient of the output to the corresponding slice of the input gradient 
%             dLdX(l1:l2-1, :, :) = dLdY; 
%             
%             
%         end
     end
end