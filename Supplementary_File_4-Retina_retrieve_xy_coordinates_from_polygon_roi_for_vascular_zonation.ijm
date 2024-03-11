// 05/31/2022 Retina_retrieve_xy_coordinates_from_polygon_roi_for_vascular_zonation

// Input are manually drawn and saved ROI sets for different vascular zones in each retina.
// ROI from one specific vascular zone of one specific retina were saved as one zip file in the roi folder.
// Output is a txt file that has x y coordinates (as pixels) for each roi in each vascular zone for all the retinas. 
// The txt output file will be used for downstream analysis of vascular zonation in R

// More to know before you start
// Before you run this script, you need to open a stitched image (jpeg is fine) of the largest retina
// in the batch of retinas you’re analyzing (make sure you use the largest retina to ensure correct coordinates being exported). 
// The input directory can only have .zip files and there cannot be any spaces in the file names so rename them if needed.
// When imagej prompts you for directory, just select the folder where all the roi files are in as the roi directory
// and then the "vascular_zonation" folder as the output folder 

run("Clear Results");
setBatchMode(true);

input = getDirectory("Choose roi Directory... ");

output = getDirectory("Choose output directory...");

list = getFileList(input);

// adding column names to the final output txt file, 
// the results will appear in a "log" window because we used the "print" function
print("AnchorPoint", "x", "y","RetinaID_VasZone","Vessel#");

for (i = 0; i < list.length; i++)
{	
	// each file is a zip file containing one specific type of vasculature, e.g. PA from one retina
		file = input + list[i];
		open(file);
		roiManager("Open",file);
		// zone should contain both retina ID and vascular zone info
		zone = File.getNameWithoutExtension(file);

	// in each zip file, there are multiple polygon ROI, process one by one
	for (k = 0; k < roiManager("count"); k++)
	{		
	roiManager("Select", k);
	Roi.getCoordinates(x, y);
		for (j=0; j<x.length; j++)
     	print(j, x[j], y[j],zone,k);
	}
		// need to delete all roi from the current zip file before moving to the next one
		roiManager("deselect");
		roiManager("Delete");

}

	saveAs("Text", output + "Vacular_Zonation_Original_polygon_coordinates.txt");	
					
exit;

