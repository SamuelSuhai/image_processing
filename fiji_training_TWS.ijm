// Macro for training Trainable Weka Segmentation Classifier. More info:
// https://imagej.net/plugins/tws/#:~:text=The%20Trainable%20Weka%20Segmentation%20is,to%20produce%20pixel%2Dbased%20segmentations.
// There may be issues when using a TWS version other than  v3.3.2.

DataFolder = "Where/To/Store/Training/Data"
ImageFolder = "Where/Training/Images/Are"

SaveClassFile = "Where/To/Save/Trained/Classifier"

TotalImageNames = getFileList(ImageFolder);
TotalImageNumber= TotalImageNames.length



for (image = 0; image<TotalImageNumber; image++) {
	
	// open image
	open(ImageFolder + "/" +TotalImageNames[image]);
	print("now opening..."+ImageFolder + "/" +TotalImageNames[image]);
	
	// run Weka 
	run("Trainable Weka Segmentation"); 
	wait(2000);
	
	// set settings for classifier
	min_sig = 7.0;
	max_sig = 16.0;
	call("trainableSegmentation.Weka_Segmentation.setMinimumSigma", "min_sig");
	call("trainableSegmentation.Weka_Segmentation.setMaximumSigma", "max_sig");
	
	// Background and foreground name 
	call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "Foreground");
	call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "Background");
	call("trainableSegmentation.Weka_Segmentation.setClassBalance", "true");
	call("trainableSegmentation.Weka_Segmentation.setOpacity", "25");
	
	// load training data from last image
	if (image!=0){
		call("trainableSegmentation.Weka_Segmentation.loadData", DataFolder + "/" + "data"+(image-1)+".arff");
		
		// possibly you can comment this line. It may not be necessary.
		waitForUser("Press OK when data loaded");

		selectWindow("Log");
		// Train classifier 
		call("trainableSegmentation.Weka_Segmentation.trainClassifier");
	}
	
	
	// User continues training 
	waitForUser("Check performance and add new traces untill performance satisfactory");
	
	// Save current trace data 
	call("trainableSegmentation.Weka_Segmentation.saveData", DataFolder + "/" + "data"+image+".arff");
	waitForUser("Press OK when data saved");
	selectWindow("Trainable Weka Segmentation v3.3.2");	
	run("Close");
}

// Save Classifier after training on data 
classifier_name = classifier_WFA.model;
call("trainableSegmentation.Weka_Segmentation.saveClassifier", SaveClassFile + "/classifier_name");


