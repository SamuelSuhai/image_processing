
// setting this to true will make it run a bit faster but you may not be able to follow all steps it takes
setBatchMode(false);

// what preprocessing steps you want
I_want_rotation = false;
I_want_cropping = false;
I_want_BG_subtraction = false; 
// split channels and only save one specified. If you want to save all set this to false
I_want_only_channel_x = 2; 


//get image list and save location 
image_folder = getDirectory("Select Image Directory");
save_folder =  getDirectory("_Select Save Location (Directory) where results folder should be created");
image_files = getFileList(image_folder);

// sorry for this piece of code. I know it hurts the eyes
// Create folder for saved results with name corresponding to preprocessing steps taken
image_save_folder = save_folder + "/processed"

if (I_want_rotation==true){
		image_save_folder = image_save_folder + "_Rot";
	}
if (I_want_cropping==true){
	image_save_folder = image_save_folder + "_Crop";
	}
if (I_want_BG_subtraction==true){
	image_save_folder = image_save_folder + "_BG";
	}
	
File.makeDirectory(image_save_folder); 

// main loop over images
for (i = 0; i<image_files.length;i++){

	// get  current image 
	image_name_file = image_files[i]; // image file name with .tif extension 
	full_image_path = image_folder+"/"+image_name_file;
	image_name = substring(image_name_file,0,image_name_file.length-3); // only image name without extention
	
	// open imaage 
	open(full_image_path);
	
	// rote if desired
	if (I_want_rotation==true){
		Rotate_Image (image_name_file);
	}
	
	// cropping parameters 
	upper_left_xpix = 200;
	upper_left_ypix = 200;
	width = 610; // in pixels
	heigth = 490;
	if (I_want_cropping==true){
		Crop_Image (image_name_file,upper_left_xpix,upper_left_ypix,width,heigth);
	}
	
	// BG sub parameters
	radius = 50;
	if (I_want_BG_subtraction==true){
		Subtract_BG (image_name_file,radius);
	}
	
	if (I_want_only_channel_x == false){
		// save processed stack and close all open images 
		saveAs("Tiff",  image_save_folder + "/" + image_name + ".tif");
		close("*");
	} else {
		// split channel and save selected  image and close all open images
		run("Split Channels");
		selectWindow("C" + I_want_only_channel_x + "-" + image_name_file);
		saveAs("Tiff",  image_save_folder + "/" + image_name + ".tif");
		close("*");
	}
	
	
}




// rotate images

function Rotate_Image (window_to_rotate_name){
	// Funciton rotates image: asks user to draw a line. The image will be rotated s.t. the line drawn
	// is parallel new horizon, and the start of the line will be on the left side
	selectWindow(window_to_rotate_name);
	setTool("line");
	waitForUser("Draw new horizontal line. Start will be left horizon and end will be right horizon.");
	requires("1.33o");
	getLine(x1, y1, x2, y2, width);
	if (x1==-1)
	     exit("This macro requires a straight line selection");
	angle = (180.0/PI)*atan2(y1-y2, x2-x1);
	run("Arbitrarily...", "angle="+angle+" interpolate stack");
}


function Crop_Image (window_to_crop_name,upper_left_xpix,upper_left_ypix,width,heigth){
	// Function crops image: input args. upper_left_xpix --> x coordinates in pixels of upper left corner. 
	// widht height of rectangle in pixels
	selectWindow(window_to_crop_name);
	makeRectangle(upper_left_xpix, upper_left_ypix, width, heigth);
	waitForUser("Select region for cropping. \nClick ‘OK’ when done.");
	run("Crop");
}

function Subtract_BG (window_to_subtract_name,radius){
	// This function subtracts back goround intensity from image using 'rolling ball' of certain radius 
	// radius should be at least the size of largest object_of_interest. Careful! unit of ball in pixels) 
	selectWindow(window_to_subtract_name);
	run("Subtract Background...", "rolling="+radius+" sliding stack");
}
