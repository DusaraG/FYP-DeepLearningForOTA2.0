#First phase training
We implemented all three parts of the communication system, transmitter, receiver and the channel using neural networks. This is an autoencoder model. The model was trained by simulating the channel using stochastic channel modeling.

This folder containing,
   1. the MATLAB model
   2. python model exported from MATLAB
	used the commands,

		Export the network net to TensorFlow. The exportNetworkToTensorFlow function saves the TensorFlow model in 		the Python package myModel.

		exportNetworkToTensorFlow(net,"myModel")
		Run this code in Python to load the exported TensorFlow model from the myModel package.

		import myModel
		model = myModel.load_model()
		Save the exported model in the TensorFlow SavedModel format. Saving model in SavedModel format is 			optional. You can perform deep learning workflows directly with model. For an example that shows how to 		classify an image with the exported TensorFlow model, see Export Network to TensorFlow and Classify Image.

		model.save("myModelTF")

   3. saved data base containing both transmitter and receiver parts for relevant n and k values.(Workspace data)

