// 05/31/2022 Retina_retrieve_xy_coordinates_from_polygon_roi_to_exclude_nonEC

// Vistreous vessels failed to be removed during dissection will show strong ERG staining and contaminate analysis results.
// Occasionally non-EC beyond the angiogenic front can also show weak ERG staining that may interfere with the analysis.
// Therefore, we usually draw one big polygon for all of the retina EC (not vistreous) to mathmatically (later in R)
// exclude contaminating signals before assigning vascular zones.

// Input are manually drawn and saved ROI (one polygon per retina) as zip files in the roi folder
// output is a txt file that has x y coordinates (as pixels) for each roi. 
// The txt output file will be used for downstream analysis of vascular zonation in R
// The script is basically the same as the one we used for vascular zonation (supp. file 3) but it's fine.

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
		file = input + list[i];
		open(file);
		roiManager("Open",file);
		zone = File.getNameWithoutExtension(file);

	for (k = 0; k < roiManager("count"); k++)
	{		
	roiManager("Select", k);
	Roi.getCoordinates(x, y);
		for (j=0; j<x.length; j++)
     	print(j, x[j], y[j],zone,k);
	}
		roiManager("deselect");
		roiManager("Delete");

}

	saveAs("Text", output + "Vacular_Region_polygon_coordinates.txt");	
					
exit;

