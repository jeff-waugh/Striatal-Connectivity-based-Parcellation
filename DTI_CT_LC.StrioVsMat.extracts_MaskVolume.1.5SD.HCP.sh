#!/bin/bash
#
# This script extracts the volume of striatal masks derived from striosome/matrix parcellation.
# For subsequent tractography to be meaningful, the mask volume for striosome-like and matrix-like
# masks has to be equal.
#
#

module unload fsl
module load fsl/5.0.11

experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP
cd ${experimental_directory}
rm DTI_CT_StrioVsMat.MaskVolumes.txt
echo -e "Group \t Hemisphere \t Identifier \t Matrix-like Volume, 1.5SD \t Striosome-like Volume, 1.5SD" > $experimental_directory/DTI_CT_StrioVsMat.MaskVolumes.txt

segmented_region=trStriatum

group=2018.N-1.E2
  
    for identifier in $(awk '{print $2}' HCP_peds.txt)
	do
        cd ${experimental_directory}
		
        DTI_directory=${identifier}/${identifier}_Diffusion
        cd ${experimental_directory}/${DTI_directory}.bedpostX
        rm temp_group temp_hemisphere temp_ID temp_Matrix_vol temp_Striosome_vol
        echo $directory
        echo "${group} " > temp_group
	echo "${identifier} " > temp_ID	  
       	for hemisphere1 in Left Right
	   do  
           echo "${hemisphere1} " > temp_hemisphere
           echo "testing ${hemisphere1} hemisphere"
           for region1 in Striosome Matrix
	      do	
              fslstats ${identifier}_CT_LC_${hemisphere1}-${segmented_region}_to_${region1}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -V | awk '{print $1}' > temp_${region1}_vol
  	   done
	   echo "pasting now"

	   paste temp_group temp_hemisphere temp_ID temp_Matrix_vol temp_Striosome_vol >> ${experimental_directory}/DTI_CT_StrioVsMat.MaskVolumes.txt
       	done
        rm temp_group temp_hemisphere temp_ID temp_Matrix_vol temp_Striosome_vol
    done
cat ${experimental_directory}/DTI_CT_StrioVsMat.MaskVolumes.txt

