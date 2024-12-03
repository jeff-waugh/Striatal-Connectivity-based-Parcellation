
#!/bin/bash
#
#  This script 1. defines voxels within the striatum as either Striosome-like or Matrix-like using a series of pre-defined groups, 2. uses
#  an ROI that was not included in the group of ROIs used to establish the striatal parcellation to test the premise: does the group of
#  voxels defined in step 1 behave in a striosome-like or matrix-like manner, based on subsequent connectivity?
# This script has been modified by Asim Hassan
#
#module unload fsl
#module load fsl/5.0.11

experimental_directory=/project/pediatrics/Waugh_lab/shared/Anxiety/Anxiety_Combined
masks_directory=/project/pediatrics/Waugh_lab/shared/segmentations

region1=trStriatum
group=2020.C
cd ${experimental_directory}

rm StriatalCompartmentVolume.Y-planes.${group}.txt
echo " " > StriatalCompartmentVolume.Y-planes.${group}.txt
	
for identifier in  `awk '{print $2}' subjectlist.Anxiety.Combined.ControlSubs.txt `  
   do
   directory=${experimental_directory}/${identifier}/${identifier}_Diffusion
   for hemisphere1 in Left Right
      do
	  
      twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
      cd ${experimental_directory}/ForRandomise/${twoROImask} 

      for nucleus in   trCaudate.Head_Body # trPutamen #
      do

         for compartment in  Striosome # Matrix
         do

            rm temp_ID temp_output
   
            echo "${identifier}" > temp_ID
            echo "${group}" >> temp_ID
            echo "${hemisphere1}-${nucleus}" >> temp_ID 
            echo "${compartment}" >> temp_ID     
            echo -e "\n Now processing ${identifier} for ${compartment} in the ${hemisphere1} ${nucleus}. \n \n " 

            for Yplane in `cat ${masks_directory}/list_of_Y_planes.txt `
            do
 
               fslstats ${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1.nii.gz -k ${masks_directory}/${hemisphere1}-${nucleus}.nii.gz -k ${masks_directory}/Yplane.${Yplane}.nii.gz -M | awk '{print $1}' >> temp_ID

#            fslstats ${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1.nii.gz -l 0.55 -k ${masks_directory}/${hemisphere1}-${region1}.nii.gz -k ${masks_directory}/Yplane.${Yplane}.nii.gz -V | awk '{print $1}' > temp_Striosome

            done
            paste  ${experimental_directory}/StriatalCompartmentVolume.Y-planes.${group}.txt temp_ID > temp_output
            mv temp_output ${experimental_directory}/StriatalCompartmentVolume.Y-planes.${group}.txt
            rm temp_ID temp_output
         done

         echo -e "\n \n "

      done 

#      rm temp_group temp_ID temp_hemisphere temp_Matrix temp_Striosome
      cd ${experimental_directory}
   done
done


echo -e " \n \n \n"
cat ${experimental_directory}/StriatalCompartmentVolume.Y-planes.${group}.txt
