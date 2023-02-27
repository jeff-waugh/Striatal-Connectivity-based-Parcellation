#!/bin/bash
#
#  This script 1. defines voxels within the striatum as either Striosome-like or Matrix-like using a series of pre-defined groups, 2. uses
#  an ROI that was not included in the group of ROIs used to establish the striatal parcellation to test the premise: does the group of
#  voxels defined in step 1 behave in a striosome-like or matrix-like manner, based on subsequent connectivity?
# This script has been modified by Asim Hassan
#

module unload fsl
module load fsl/5.0.11
echo "test"
experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP
cd ${experimental_directory}

	
for identifier in `awk '{print $2}' HCP_peds.txt  `
   do

   cd ${experimental_directory}
	
   directory=${experimental_directory}/${identifier}/${identifier}_Diffusion
   for hemisphere1 in Left Right
      do	   
      for region1 in trStriatum		
         do
	  	
         for group in 2020.N-1.12
	    do
               cd ${directory}.bedpostX
	       twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
	       mkdir ${directory}.bedpostX/${twoROImask}
                mkdir ${experimental_directory}/ForRandomise/${twoROImask}
		rm ${twoROImask}/targets.txt ${directory}.bedpostX/${twoROImask}/temp2.sh ${directory}.bedpostX/${twoROImask}/temp3.sh
		  seed=${identifier}_${hemisphere1}-${region1}_bin0.5.nii.gz
		  Matrix_1=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 1p`
		  Matrix_2=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 2p`
	 	  Matrix_3=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 3p`
	 	  Matrix_4=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 4p`
	 	  
		  fslmaths ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_1}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_2}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_3}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_4}_bin0.5.nii.gz -bin ${directory}.bedpostX/${identifier}_${hemisphere1}-Matrix-like_Ctx_${group}_bin0.5.nii.gz

		Striosome_1=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 1p`
		Striosome_2=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 2p`
		Striosome_3=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 3p`
		Striosome_4=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 4p`
		Striosome_5=`cat /project/radiology/ANSIR_lab/shared/s188839_workspace/Absolute/Striatal_Parcellation/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 5p`

		fslmaths ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_1}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_2}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_3}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_4}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_5}_bin0.5.nii.gz -bin ${directory}.bedpostX/${identifier}_${hemisphere1}-Striosome-like_Ctx_${group}_bin0.5.nii.gz
#
###  Adds the primary endpoint for this experiment, the Striosome- or Matrix-like cortex, to the list-file used for targetting.
#

		for region2 in Striosome-like_Ctx_${group} Matrix-like_Ctx_${group}
		do
		  echo "${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz" >> ${directory}.bedpostX/${twoROImask}/targets3.txt
		  echo "mv ${directory}.bedpostX/${twoROImask}/seeds_to_${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz ${directory}.bedpostX/${twoROImask}/${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline.nii.gz" >> ${directory}.bedpostX/${twoROImask}/temp2.sh
		  echo "applywarp --ref=${experimental_directory}/FMRIB58_FA_1mm.nii.gz --in=${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz --warp=../${identifier}_transtostandard.mat.nii.gz --out=${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz" >> ${directory}.bedpostX/${twoROImask}/temp3.sh
		  echo "cp ${twoROImask}/${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz ${experimental_directory}/ForRandomise/${twoROImask}" >> ${directory}.bedpostX/${twoROImask}/temp3.sh
		done
               	echo "proj_thresh ${identifier}_CT_LC_${hemisphere1}-${region1}_to_*like_Ctx_${group}_excludesMidline.nii.gz 1" >> ${directory}.bedpostX/${twoROImask}/temp2.sh


###  Adds the remaining targets to the list-file - in this case, all of the regions that are added to make the
#    Striosome-like or Matrix-like cortex target masks
		 # for region3 in trPMC trAntInsula BA_1_2_3 trOrbitofrontal_Area13 GyrusRectus trAntCingulate_pregenual trSMC Pulvinar Pallidum.symm trAmygdala BasolateralAmygdala CentralAmygdala
		#	do
 	         #    echo "${identifier}_${hemisphere1}-${region3}_bin0.5.nii.gz" >> ${directory}.bedpostX/${twoROImask}/targets.txt
		 # done
#
### Adds probtrackx2 runs to file for launchpad submission, Reversed Targets
#
#

		 rm ${directory}.bedpostX/${twoROImask}/temp1
		 echo "#\!/bin/bash \n# \n#" >> ${directory}.bedpostX/temp1
		 echo "module unload fsl" >> ${directory}.bedpostX/temp1
		 echo "module load fsl/5.0.11" >> ${directory}.bedpostX/temp1
		 echo "cd ${directory}.bedpostX" >> ${directory}.bedpostX/temp1
		 echo "probtrackx2 --seed=${seed} -l --loopcheck --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd --samples=merged --avoid=${identifier}_MidlinePlane.FA_bin0.5.nii.gz --mask=nodif_brain_mask.nii.gz --dir=${twoROImask}/ --targetmasks=${twoROImask}/targets3.txt --os2t --pd --out=${identifier}_ptracx_${twoROImask}.nii.gz" >> ${directory}.bedpostX/temp1

		 mv ${directory}.bedpostX/temp1 ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh
                 echo "cd ${twoROImask}" >> ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh
		 echo "sh ${directory}.bedpostX/${twoROImask}/temp2.sh" >> ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh
		 echo "sh ${directory}.bedpostX/${twoROImask}/temp3.sh" >> ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh
sh ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh &
sleep 30s

#done
done

sleep 6m

done

done
done
mv tempA.txt ParcellatesStriatumGroupof10.txt
mv tempB.txt temp2runs.txt
mv tempC.txt temp3runs.txt
