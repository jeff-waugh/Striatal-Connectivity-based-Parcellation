#!/bin/bash
#
#  This script 1. defines voxels within the striatum as either Striosome-like or Matrix-like using a series of pre-defined groups, 2. uses
#  an ROI that was not included in the group of ROIs used to establish the striatal parcellation to test the premise: does the group of
#  voxels defined in step 1 behave in a striosome-like or matrix-like manner, based on subsequent connectivity?
# This script has been modified by Asim Hassan
#
#module unload fsl
#module load fsl/5.0.11

experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP/S1200
masks_directory=/project/pediatrics/Waugh_lab/shared/segmentations/StrioVsMat

region1=trStriatum
group=2024.C
cd ${experimental_directory}

	
for identifier in `cat temp1115.txt `
   do
   directory=${experimental_directory}/${identifier}/${identifier}_Diffusion
   for hemisphere1 in  Right Left
      do
	  
#      fslmaths ${directory}.bedpostX/${identifier}_${hemisphere1}-trCaudate.Head_Body_S0subtracted_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-trPutamen_bin0.5.nii.gz -bin ${directory}.bedpostX/${identifier}_${hemisphere1}-trStriatum_S0subtracted_bin0.5.nii.gz

       fslmaths ${directory}.bedpostX/nodif_brain_mask.nii.gz -mas ${directory}.bedpostX/${identifier}_MNI152_${hemisphere1}_hemisphere_block_mask_bin0.5.nii.gz ${directory}.bedpostX/nodif_brain_mask.${hemisphere1}-hemisphere.nii.gz

      twoROImask=${hemisphere1}-${region1}_StrioVsMat_${group}_CT_LC.ipsi.redoneBNSTmask	
      mkdir ${directory}.bedpostX/${twoROImask}  
      mkdir ${experimental_directory}/ForRandomise/${twoROImask}  

      rm ${directory}.bedpostX/${twoROImask}/targets.txt ${directory}.bedpostX/${twoROImask}/temp2.sh ${directory}.bedpostX/${twoROImask}/temp3.sh
	  
      seed=${identifier}_${hemisphere1}-${region1}_bin0.5.nii.gz

      Matrix_1=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 1p`	  
      Matrix_2=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 2p` 	  
      Matrix_3=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 3p` 	  
      Matrix_4=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 4p` 	  
      Matrix_5=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 5p`	  
      fslmaths ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_1}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_2}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_3}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_4}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Matrix_5}_bin0.5.nii.gz -bin ${directory}.bedpostX/${identifier}_${hemisphere1}-Matrix-like_Ctx_${group}_bin0.5.nii.gz

		
      Striosome_1=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 1p`
      Striosome_2=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 2p`	
      Striosome_3=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 3p`
      Striosome_4=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 4p`
      Striosome_5=`cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 5p`	
      fslmaths ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_1}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_2}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_3}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_4}_bin0.5.nii.gz -add ${directory}.bedpostX/${identifier}_${hemisphere1}-${Striosome_5}_bin0.5.nii.gz -bin ${directory}.bedpostX/${identifier}_${hemisphere1}-Striosome-like_Ctx_${group}_bin0.5.nii.gz


#
###  Adds the primary endpoint for this experiment, the Striosome- or Matrix-like cortex, to the list-file used for targetting.
#	
      for region2 in Striosome-like_Ctx_${group} Matrix-like_Ctx_${group}	
         do
	 echo "${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz" >> ${directory}.bedpostX/${twoROImask}/targets.txt
	 echo "mv seeds_to_${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline.nii.gz" >> ${directory}.bedpostX/${twoROImask}/temp2.sh
	 echo "applywarp --ref=/project/pediatrics/Waugh_lab/shared/segmentations/FMRIB58_FA_1mm.nii.gz --in=${directory}.bedpostX/${twoROImask}/${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz --warp=${directory}/${identifier}_transtostandard.mat.nii.gz --out=${directory}.bedpostX/${twoROImask}/${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz" >> ${directory}.bedpostX/${twoROImask}/temp3.sh
	 echo "cp ${directory}.bedpostX/${twoROImask}/${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz ${experimental_directory}/ForRandomise/${twoROImask}" >> ${directory}.bedpostX/${twoROImask}/temp3.sh
      done
      echo "proj_thresh ${identifier}_CT_LC_${hemisphere1}-${region1}_to_*like_Ctx_${group}_excludesMidline.nii.gz 1" >> ${directory}.bedpostX/${twoROImask}/temp2.sh


###  Adds the remaining targets to the list-file - in this case, all of the regions that are added to make the
#    Striosome-like or Matrix-like cortex target masks


      for region3 in $(cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $1}')	      
         do
         echo "${identifier}_${hemisphere1}-${region3}_bin0.5.nii.gz" >> ${directory}.bedpostX/${twoROImask}/targets.txt
      done

      for region4 in $(cat ${masks_directory}/StriosomeVsMatrix.${group}.txt | awk '{print $2}')	      
         do
         echo "${identifier}_${hemisphere1}-${region4}_bin0.5.nii.gz" >> ${directory}.bedpostX/${twoROImask}/targets.txt
      done     

cat ${directory}.bedpostX/${twoROImask}/targets.txt
echo "  "
echo "  "

#
### Adds probtrackx2 runs to file for launchpad submission, Reversed Targets
#
#
		 
      rm ${directory}.bedpostX/${twoROImask}/temp1	  
      echo "#\!/bin/bash \n# \n#" >> ${directory}.bedpostX/temp1	
      echo " module unload fsl" >> ${directory}.bedpostX/temp1
      echo "module load fsl/5.0.11" >> ${directory}.bedpostX/temp1
      echo "cd ${directory}.bedpostX" >> ${directory}.bedpostX/temp1	 
      echo "probtrackx2 --seed=${seed} -l --loopcheck --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd --samples=merged --mask=nodif_brain_mask.${hemisphere1}-hemisphere.nii.gz --dir=${twoROImask}/ --targetmasks=${twoROImask}/targets.txt --os2t --pd --out=${identifier}_ptracx_${twoROImask}.nii.gz" >> ${directory}.bedpostX/temp1
		  
      echo "cd ${twoROImask}" >> ${directory}.bedpostX/temp1	 
      echo "sh temp2.sh" >> ${directory}.bedpostX/temp1    
      echo "sh temp3.sh" >> ${directory}.bedpostX/temp1	 
      mv ${directory}.bedpostX/temp1 ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh
		
      echo "bash ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh" >> Parcellationruns8yo.txt

sh ${directory}.bedpostX/${twoROImask}/temp_ptracx_${identifier}_${twoROImask}.sh &
sleep 45s


   done
#sleep 2m
done

