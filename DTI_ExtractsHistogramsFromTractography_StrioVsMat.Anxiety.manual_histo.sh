#!/bin/bash

#
#module unload fsl
#module load fsl/5.0.11

experimental_directory=/project/pediatrics/Waugh_lab/shared/Anxiety/BANDA/NDAR_Anxiety

region1=trStriatum
group=2020.C
round=1

cd ${experimental_directory}
echo -e "." > ${experimental_directory}/StriatalCompartmentVolume.${group}.txt

rm StriatalCompartmentVolume.${group}.txt
	
for identifier in  . . `awk '{print $1}' subjectlist.Anxiety.BANDA.Anxiety48.txt `  #  NDAR_INVNC929BXM    NDAR_INVWR348JZK
  do
   directory=${experimental_directory}/${identifier}/${identifier}_Diffusion
   for hemisphere in  Left Right # 
      do
      for compartment in   Striosome #  Matrix #
      do
         cd ${directory}.bedpostX 

	 rm temp_identifier temp_${hemisphere}_${compartment} temp1 temp3

         echo "${identifier}  " > temp_identifier
         echo "${hemisphere}-${compartment}" >> temp_identifier 
         echo "${group}" >> temp_identifier

         upper_thresh=1.00000001
         lower_thresh=1000

         while  [[ ${lower_thresh} -gt "100" ]];
         do
       
            lower_thresh=`expr "${lower_thresh}" - 15`
            echo -e "lower_thresh is ${lower_thresh}"
            fslstats ${hemisphere}-${region1}_${group}_classification_targets_excludesMidline.length_corrected/${identifier}_CT_LC_${hemisphere}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_proj_seg_thr_1.nii.gz -l 0.${lower_thresh} -u ${upper_thresh} -V | awk '{print $2}' | cut -c 1-6 >> temp_identifier

            upper_thresh=0.${lower_thresh}0001
         done

         while  [[ ${lower_thresh} -gt "0" ]];
         do
       
            lower_thresh=`expr "${lower_thresh}" - 15`
            echo -e "lower_thresh is ${lower_thresh}"
            fslstats ${hemisphere}-${region1}_${group}_classification_targets_excludesMidline.length_corrected/${identifier}_CT_LC_${hemisphere}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_proj_seg_thr_1.nii.gz -l 0.0${lower_thresh} -u ${upper_thresh} -V | awk '{print $2}' | cut -c 1-6 >> temp_identifier

            upper_thresh=0.0${lower_thresh}0001
         done


         if  [[ ${round} -gt "0" ]];
         then
            mv temp_identiifer ${experimental_directory}/StriatalCompartmentVolume.${group}.txt
            round=0
         else
            paste ${experimental_directory}/StriatalCompartmentVolume.${group}.txt temp_identifier > temp3.txt
            mv temp3.txt ${experimental_directory}/StriatalCompartmentVolume.${group}.txt
            rm temp_identifier 
          fi
      done
   done
echo -e "\n \n"

      cd ${experimental_directory}
done


echo -e " \n \n \n"
cat ${experimental_directory}/StriatalCompartmentVolume.${group}.txt
