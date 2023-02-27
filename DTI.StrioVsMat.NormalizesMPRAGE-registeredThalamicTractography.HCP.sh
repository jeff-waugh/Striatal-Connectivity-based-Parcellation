

#!/bin/bash

module unload fsl
module load fsl/5.0.11

module unload freesurfer
module load freesurfer/7.1.1

group=2020.C

ROI=Reuniens

experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP

tractography=${ROI}_to_StriosomeVsMatrix_CT_LC_${group}_1.5SDthresh_Way.trGlobusPallidusInterna.subcortical_mask

cd ${experimental_directory}

for identifier in `awk '{print $2}' HCP100_adults.txt`
do

#   echo ${identifier}

   FA_dir=${experimental_directory}/${identifier}/${identifier}_Diffusion

   for hemisphere in Left Right
   do
   
      cd ${FA_dir}.bedpostX/500K.${hemisphere}-${tractography}

#echo "test4"

      rm temp.M.0.1.nii.gz temp.S.0.1.nii.gz temp.normalizing.nii.gz normalized.500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Striosome-like_trStriatum*_PT1_1.5SDthresh_PT1.nii.gz

      fslmaths 500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Matrix-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz -thr 0.1 temp.M.0.1.nii.gz
      fslmaths 500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Striosome-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz -thr 0.1 temp.S.0.1.nii.gz
      fslmaths temp.M.0.1.nii.gz -add temp.S.0.1.nii.gz -thr 0.3 temp.normalizing.nii.gz

echo -e "\n \n \n \n \n Max value for ${hemisphere} ${identifier}'s normalizing mask is `fslstats temp.normalizing.nii.gz -R | awk '{print $2}'`. \n"

       fslmaths 500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Matrix-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz -div temp.normalizing.nii.gz normalized.500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Matrix-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz

       fslmaths 500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Striosome-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz -div temp.normalizing.nii.gz normalized.500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Striosome-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz

       echo -e " Max value for the normalized ${hemisphere} matrix is `fslstats normalized.500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Matrix-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz -R  | awk '{print $2}'`. "

       echo -e " Max value for the normalized ${hemisphere} striosome is `fslstats normalized.500K.${identifier}_CT_LC_toMPRAGE_${hemisphere}-${ROI}_to_Striosome-like_trStriatum_${group}_PT1_1.5SDthresh_PT1.nii.gz -R  | awk '{print $2}'`. "

      rm temp.M.0.1.nii.gz temp.S.0.1.nii.gz temp.normalizing.nii.gz

   done
done

