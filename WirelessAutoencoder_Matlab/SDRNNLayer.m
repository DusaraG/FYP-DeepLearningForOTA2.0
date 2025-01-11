classdef SDRNNLayer < nnet.layer.Layer
    properties
        l = 6;
        n = 4;
        r = 4;
        units = 16;
        fe
        pe
        oe
    end
    
    methods
        function layer = SDRNNLayer(varargin)
            % Constructor for SD_RNN custom layer
              p = inputParser;
              addParameter(p,'l',6)
              addParameter(p,'n',4)
              addParameter(p,'r',4)
              addParameter(p,'units',16)
              addParameter(p,'Name','SDRNN')
              addParameter(p,'Description','')
              
              parse(p,varargin{:})
        
              layer.l = p.Results.l;
              layer.n = p.Results.n;
              layer.r = p.Results.r;
              layer.units = p.Results.units;
              layer.Name = p.Results.Name;
        
              if isempty(p.Results.Description)
                layer.Description = "SDRNN";
              else
                layer.Description = p.Results.Description;
              end
      
            
            % Define sub-networks (fe, pe, oe)
            layer.fe = dlnetwork([
                sequenceInputLayer(92, 'Name', 'feature_input')
                fullyConnectedLayer(256, 'Name', 'fe_initial'),
                reluLayer
                fullyConnectedLayer(8, 'Name', 'fe_output')
            ]);
            
            layer.pe = dlnetwork([
                sequenceInputLayer(92, 'Name', 'phase_input')
                fullyConnectedLayer(256, 'Name', 'pe_initial')
                reluLayer
                fullyConnectedLayer(128, 'Name', 'pe_dense1')
                reluLayer
                fullyConnectedLayer(2, 'Name', 'pe_output')
            ]);
            
            layer.oe = dlnetwork([
                sequenceInputLayer(92, 'Name', 'offset_input')
                fullyConnectedLayer(256, 'Name', 'oe_initial')
                reluLayer
                fullyConnectedLayer(128, 'Name', 'oe_dense1')
                reluLayer
                fullyConnectedLayer(32, 'Name', 'oe_dense2')
                reluLayer
                fullyConnectedLayer(16, 'Name', 'oe_output')
                softmaxLayer
            ]);
        end
        
        function output = predict(layer, X)
            % Get the input dimension
            inDim = size(X, 1);
            display(inDim)
            display(layer.pe)
          
            %feNet = dlnetwork(layer.fe);
            %peNet = dlnetwork(layer.pe);
            %oeNet = dlnetwork(layer.oe);
   
            X = dlarray(X,"CBT");

            % Split real and imaginary parts
            halfDim = inDim/2;
            realPart = X(1:halfDim,:,:);
            imagPart = X(halfDim + 1:end,:,:);
            realPart = reshape(realPart,size(realPart,1),size(realPart,2),[]);
            imagPart = reshape(imagPart,size(imagPart,1),size(imagPart,2),[]);
            display(realPart)
            display(imagPart)
            
            % Apply mini_slicer (Slicing part)
            mini_inputs = layer.mini_slicer(X);
            X_dlarr = dlarray(X,"CBT");

            h = predict(layer.pe,X_dlarr);
            display(h)
            hReal = h(1, :,:);
            hImag = h(2, :,:);
            
            % Feature extractor and offset estimator
            featureExtractOutput = predict(layer.fe, X_dlarr);
            display(featureExtractOutput )
            offsetEstimatorOutput = predict(layer.oe, X_dlarr);
            display(offsetEstimatorOutput)
            
            % Concatenate the outputs
            output = cat(1, mini_inputs, hReal, hImag, featureExtractOutput, offsetEstimatorOutput);
            display(output)
            output = extractdata(output);
            display(output)

        end

         % Mini Slicer Method
        function output = mini_slicer(layer, inputs)
            % Calculate slicing index based on layer properties
            N_msg = layer.r * layer.n;
            l1 = 30 + (layer.l) * 2 * N_msg;
            l2 = 30 + (layer.l + 1) * 2 * N_msg;
            
            % Slice the inputs based on computed indices
            output = inputs(l1:l2-1,:,:); % Adjust indices accordingly
            disp(['mini slice output shape: ', num2str(size(output))]);
        end
        
        function gradients = backward(layer, X, target, ~, ~)
            % Forward pass
            output = predict(layer, dlarray(X,"CBT"));
            
            % Compute loss (Mean Squared Error as example)
            loss = mse(dlarray(output), dlarray(target));
            
            % Compute gradients using dlgradient (handles backpropagation)
            gradients.fe = dlgradient(loss, layer.fe.Learnables);
            gradients.pe = dlgradient(loss, layer.pe.Learnables);
            gradients.oe = dlgradient(loss, layer.oe.Learnables);
            
            % Optionally, you can return the gradient w.r.t inputs if needed
            gradients.input = dlgradient(loss, X);
        end

    end
end