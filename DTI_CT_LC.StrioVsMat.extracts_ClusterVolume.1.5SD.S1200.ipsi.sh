#!/bin/bash
#
# This script extracts the volume of striatal masks derived from striosome/matrix parcellation.
# For subsequent tractography to be meaningful, the mask volume for striosome-like and matrix-like
# masks has to be equal.
#
#

module unload fsl
module load fsl/6.0.7.11

experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP/S1200
cd ${experimental_directory}
rm DTI_CT_StrioVsMat.ClusterVolumes.txt
echo -e "Group \t Hemisphere \t Identifier \t Mat, Cluster Vol \t Strio, Cluster Vol " > $experimental_directory/DTI_CT_StrioVsMat.ClusterVolumes.txt

segmented_region=trStriatum

group=2020.C
  
    for identifier in $(awk '{print $1}' subjectlist.S1200.674Controls.txt )
	do
        cd ${experimental_directory}
		
        DTI_directory=${identifier}/${identifier}_Diffusion
        cd ${experimental_directory}/${DTI_directory}.bedpostX
        rm temp_group temp_hemisphere temp_ID temp_*cluster
        echo $directory
        echo "${group} " > temp_group
	echo "${identifier} " > temp_ID	  
       	for hemisphere1 in Left Right
	   do  
           echo "${hemisphere1} " > temp_hemisphere
           echo "testing ${hemisphere1} hemisphere"
           for region1 in Striosome Matrix
	      do

              fsl-cluster --in=${hemisphere1}-${segmented_region}_StrioVsMat_${group}_CT_LC.ipsi/${identifier}_CT_LC_${hemisphere1}-${segmented_region}_to_${region1}-like_Ctx_${group}_excludesMidline_proj_seg_thr_1.nii.gz --thresh=0.55 | sed -n '3,3p;4q' | awk '{print $2}' > temp_${region1}_cluster

  	   done

	   echo "pasting now"

	   paste temp_group temp_hemisphere temp_ID temp_Matrix_cluster temp_Striosome_cluster >> ${experimental_directory}/DTI_CT_StrioVsMat.ClusterVolumes.txt
       	done
        rm temp_group temp_hemisphere temp_ID temp_*cluster
    done
cat ${experimental_directory}/DTI_CT_StrioVsMat.ClusterVolumes.txt

