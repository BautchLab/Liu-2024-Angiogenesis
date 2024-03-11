// 09/01/2022 Retina_EC_PIP-FUCCI_int_by_ERG-647_on_20x_MATL_images_ZL

// Input are 20x stitched MATL retina images (Z stack, one huge image per retina),
// Phase 1: C1 = IB4-405 C2 = Geminin-mCherry, C3 = Cdt1-mVenus, C4= ERG-647

// Purpose
// This is an automated script to quantify PF intensity in EC from neonatal retinas
// The script handles .oir input files in batch mode (stitched 20x MATL Z stack images in a folder).
// The final purpose is to take output numbers into R and explore the relationships among the measured proteins 
// in each single nucleus, then compare that among different vascular zones

// How it works
// First, background subtraction was performed before maximum intensity projection, which condense the Z stack into one 2D image
// then a mask is made with ERG channel (C4) and applied to C2, C3 to measure their intensities in each EC nucleus
// The following files are generated in the output folder
// 1. exported jpeg images of each channel/merged channels and images with ROI labeled and numbered 
// 2. intensity per nucleus of C2 and C3, exported as one big .csv file containing measurements from all images

// More to know before you start
// The input directory can only have .oir files in it and there cannot be any spaces in the file names so rename them if needed.
// When imagej prompts you for directory, just select the folder where all the .oir files are in as the input folder
// and then the output folder you created beforehand

run("Clear Results");
setBatchMode(true);

input = getDirectory("Choose image Directory... ");

output = getDirectory("Choose saving directory...");

list = getFileList(input);

for (i = 0; i < list.length; i++)
{	
		file = input + list[i];
		open(file);
		T = getTitle();
		selectWindow(T);

	run("Split Channels");
	
		selectWindow("C2-"+T);
	run("Subtract Background...", "rolling=50 stack");
	run("Z Project...", "projection=[Max Intensity]");	
		selectWindow("C3-"+T);
	run("Subtract Background...", "rolling=50 stack");
	run("Z Project...", "projection=[Max Intensity]");	
		selectWindow("C4-"+T);
	run("Subtract Background...", "rolling=50 stack");
	run("Z Project...", "projection=[Max Intensity]");	
		selectWindow("C1-"+T);
	run("Subtract Background...", "rolling=50 stack");
	run("Z Project...", "projection=[Max Intensity]");	

		// now select the ERG channel, duplicate image & make ERG mask
		selectWindow("MAX_C4-"+T);
		run("Duplicate...", " ");	
		setAutoThreshold("Default dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");

		// Set the measurement to the current image and meaure C2, C3
		run("Set Measurements...","area mean centroid display redirect=MAX_C2-" + T + " decimal=2");
		// size=20-200 ensures exclusion of debri/non-specific staining (< 20) and doublets (big > 200)
		// Results were not saved for individual images but for all images as one csv file after looping
		// So in the Analyze particle step it is important to not clear results from previous images
		// # of particles in this image has been added to the summary tab
		run("Analyze Particles...", "size=40-200 show=[Overlay Masks] display exclude include add");
		
		run("Set Measurements...","area mean centroid display redirect=MAX_C3-" + T + " decimal=2");
		run("Analyze Particles...", "size=40-200 show=[Overlay Masks] display exclude include");
		
		// save the image showing overlay of ROI on ERG
		run("Labels...", "color=red font=20 show");
        run("Flatten");
		saveAs("Jpeg",output + T+"_ROI_overlay_ERG_mask.jpg");
		close();
		close();
		
		// now select the ERG channel again, convert to mask and save black and white image
		selectWindow("MAX_C4-"+T);
		run("Blue");
		run("Duplicate...", " ");	
		//setThreshold(1500,65505);
		setAutoThreshold("Default dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Invert LUT");
		saveAs("Jpeg", output + T+"_ERG_black&white.jpg");
      	close();// close the black & white image

		// save IB4 as gray	
		selectWindow("MAX_C1-"+T);
        run("Duplicate...", " ");	
        run("Grays");
        run("Invert LUT");
        setMinAndMax(30, 2000);
        run("RGB Color");
		saveAs("Jpeg",output + T+"_IB4.jpg");
		close();
		close();//close C1
		
		// save mCherry as red	
		selectWindow("MAX_C2-"+T);
        run("Red");
        run("Duplicate...", " ");	
		run("RGB Color");
		saveAs("Jpeg",output + T+"_mCherry.jpg");
		run("From ROI Manager");
		run("Labels...", "color=white font=20 show");
		run("Flatten");
		saveAs("Jpeg",output + T+"_ROI_overlay_mCherry.jpg");
		close();
		close();

		// save mVenus as green	
		selectWindow("MAX_C3-"+T);
        run("Green");
        run("Duplicate...", " ");	
		run("RGB Color");
		saveAs("Jpeg",output + T+"_mVenus.jpg");
		run("From ROI Manager");
		run("Labels...", "color=white font=20 show");
		run("Flatten");
		saveAs("Jpeg",output + T+"_ROI_overlay_mVenus.jpg");
		close();
		close();

		//ERG (blue) + mCherry
		run("Merge Channels...", "c1=MAX_C4-"+T+" c2=MAX_C2-"+T+" create keep");
		run("Stack to RGB");
		saveAs("Jpeg",output + T+"_ERG_mCherry.jpg");
		close();

		//ERG (blue) + mVenus
		run("Merge Channels...", "c1=MAX_C4-"+T+" c2=MAX_C3-"+T+" create keep");
		run("Stack to RGB");
		saveAs("Jpeg",output + T+"_ERG_mVenus.jpg");
		close();

		//PF
		run("Merge Channels...", "c1=MAX_C2-"+T+" c2=MAX_C3-"+T+" create keep");
		run("Stack to RGB");
		saveAs("Jpeg",output + T+"_PF.jpg");
		close();

		//ERG (blue) + mCherry  + mVenus
		run("Merge Channels...", "c1=MAX_C2-"+T+" c2=MAX_C3-"+T+" c3=MAX_C4-"+T+" create");
		run("Stack to RGB");
		saveAs("Jpeg",output + T+"_ERG_PF.jpg");
		close();

		// need to delete all roi from the current image before moving to the next one
		roiManager("Delete");

}

saveAs("Results",output + "mCherry(C2)_mVenus(C3)_intensity.csv");
					
exit;

	
