#!/bin/bash
# 
#  This script aims to equalize the numbers of voxels in a striosome-like or matrix-like striatal mask. It eliminates the middle 
#  3 Standard Deviations (1.5 SD above and below the mean, hence 1.5SD in the final mask file name), assuring that only the uppermost ~76 voxels of the striatum are kept.
#  This makes it less likely that a subject's striatum dominated by one compartment will "win all" and thus misattribute the 
#  parcellated striatal voxels.
#  Empirically, setting the target_threshold a little below the desired voxel number will yield approximately your target. This is why
#  v1.0 starts with a target_threshold of 75, hoping for a final mask size of 75-80.
#
#
module unload fsl
module load fsl/5.0.11
group=2018.N-1.12
region1=trStriatum
threshold_volume=180

experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP
cd ${experimental_directory}
rm 1.5SDthresh_runs_that_are_too_big.${group} 1.5SDthresh_runs_that_need_attention.${group}

for identifier in `awk '{print $2}' HCP100_adults.txt ` 
#` awk '{print $1}' temp12w67.txt` 
#`cat temp3f.txt`
do
	cd ${experimental_directory}
	directory=${experimental_directory}/${identifier}/${identifier}_Diffusion

	for hemisphere1 in Left Right
	   do	
####
           twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
	   for region2 in Striosome-like_Ctx_${group} Matrix-like_Ctx_${group} 
              do
	      echo "Now processing ${hemisphere1}-${region2} for ${identifier}."
		
##   The line below writes the subject name and hemisphere-region into a text file. If the subject's mask file is big enough to pass threshold (entering the loop below), then this
#    line is removed. If it's not removed, then at the end of the script this file will be read out as subjects needing manual attention.

              echo "${identifier} ${hemisphere1}-${region1}_to_${region2}.${group}" >> ${experimental_directory}/1.5SDthresh_runs_that_need_attention.${group}.txt

 	      for thresholdA in 9 8 7 6 5 
	        do
                for thresholdB in 9 8 7 6 5 
                   do
                   for thresholdC in 9 8 7 6 5 4 3 2 1 0  
                     do
                     working_threshold=0.${thresholdA}${thresholdB}${thresholdC}

           cd ${directory}.bedpostX/${twoROImask}/
           target_volume=`fslstats ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -l ${working_threshold} -V | awk '{print $1}' `
	   echo "The target volume is: $target_volume. The Threshold volume is $threshold_volume."
   	   if [[ ${target_volume} -le  ${threshold_volume} ]]; then
   	      fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -thr 0.55 -bin ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1_1.5SDthresh.nii.gz
	   else

           for thresholdD in 9 8 7 6 5 4 3 2 1 0 
              do
              for thresholdE in 9 8 7 6 5 4 3 2 1 0
                 do
                 for thresholdF in 9 8 7 6 5 4 3 2 1 0
                    do
                    working_threshold=0.${thresholdA}${thresholdB}${thresholdC}${thresholdD}${thresholdE}${thresholdF}
 
                    target_volume=`fslstats ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

echo $target_volume
echo $threshold_volume
echo " "

  	            if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	               echo "Using $working_threshold as a threshold yields a mask that is too small"

	            elif [[ ${target_volume} ==  ${threshold_volume} ]]; then	
	               echo "The mask threshold for ${identifier}, ${group}, ${hemisphere1} ${region2} is ${working_threshold}, which yields a mask with ${target_volume} voxels."
                       echo "  "
                       echo "  "
                       echo "  "
	               grep -vwE ${identifier}_${hemisphere1}-${region1}_to_${region2}.${group} ${experimental_directory}/1.5SDthresh_runs_that_need_attention.${group}.txt > temp.txt
	               mv temp.txt ${experimental_directory}/1.5SDthresh_runs_that_need_attention.${group}.txt
     	               fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -thr ${working_threshold} -bin ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1_1.5SDthresh.nii.gz
	               mv ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
      	               break 6
                    elif [[ ${target_volume} -gt  ${threshold_volume} ]]; then
	    	       echo "${identifier} ${hemisphere1}-${region1}_to_${region2} yielded a mask of ${target_volume}." >> ${experimental_directory}/1.5SDthresh_runs_that_are_too_big.${group}                    
                       break 6
	            fi
                 done
              done
           done
        fi         
      done
    done
  done
done       
done
done


#
### Now takes the runs that were too big, adjusts the classification_targets file (using fslmaths) of the too-big member and re-runs proj_thresh
#
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "Now processing masks that were too big following the standard approach"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo "##########"
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
#
cd ${experimental_directory}
   
rm temp_Left_Matrix.${group} temp_Left_Striosome.${group} temp_Right_Matrix.${group} temp_Right_Striosome.${group} temp 
grep Left 1.5SDthresh_runs_that_are_too_big.${group} | grep Matrix > temp_Left_Matrix.${group}   
grep Left 1.5SDthresh_runs_that_are_too_big.${group} | grep Striosome > temp_Left_Striosome.${group}   
grep Right 1.5SDthresh_runs_that_are_too_big.${group} | grep Matrix > temp_Right_Matrix.${group}
grep Right 1.5SDthresh_runs_that_are_too_big.${group} | grep Striosome > temp_Right_Striosome.${group}

threshold_volume=180

for denominator in 1.25 1.5 1.75 2 2.5 3 3.5 4 5 8 12 16 20 25 100 115 5000 6500 200 220 600 750 1500 1750 12000 13000 20000 22000 30000 35000 70000 80000 120000 130000 300000 305000 310000 400000 405000 410000 2000 2100 2200 8000 8100 17000 18000 27000 27500 28000 33000 34000 35000 37000 39000 41000 44000 40000 50000 60000 62000 64000 60 61 62 250 255 260 7500 7600 7700 15000 15200 55000 65000 
   do

   echo " ####### "
   echo " ####### "
   echo " ####### "
   echo "Now utilizing ___${denominator}___ as the denominator."
   echo " ####### "
   echo " ####### "
   echo " ####### "




   cd ${experimental_directory}
   for identifier_Left_Striosome in $(cat temp_Left_Striosome.${group} | awk '{print $1}')
      do

      echo -e "Now working on $identifier_Left_Striosome, Left Striosome - at Denominator = ${denominator}"

      directory=${experimental_directory}/${identifier_Left_Striosome}/${identifier_Left_Striosome}_Diffusion

      cd ${directory}.bedpostX/Left-${region1}_${group}_classification_targets_excludesMidline.length_corrected
  
      rm temp*nii.gz
      fslmaths ${identifier_Left_Striosome}_CT_LC_Left-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz

      cp ${identifier_Left_Striosome}_CT_LC_Left-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      for threshold2 in 9 8 7 6 5 4 3 2 1 0
	do
        for threshold3 in 9 8 7 6 5 4 3 2 1 0
           do

           working_threshold=0.${threshold2}${threshold3}
           target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

           if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	     echo "Using $working_threshold as a threshold yields a mask that is too small."
           
           elif [[ ${target_volume} -ge  ${threshold_volume} ]]; then
             for threshold4 in 9 8 7 6 5 4 3 2 1 0
               do
               for threshold5 in 9 8 7 6 5 4 3 2 1 0
                 do
                 working_threshold=0.${threshold2}${threshold3}${threshold4}${threshold5}

                 target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

echo $target_volume
echo $threshold_volume
echo " "

  	         if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	           echo "Using $working_threshold as a threshold yields a mask that is too small"

	         elif [[ ${target_volume} ==  ${threshold_volume} ]]; then	
#	           echo "${identifier_Left_Striosome} Left Striosome" 			

                   target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}' `
                   echo "   ###   "
	           echo "The mask threshold for ${identifier_Left_Striosome}, ${group}, Left Striosome is ${working_threshold}, which yields a mask with ${target_volume} voxels."
                   echo "   ###   "

	           grep -vwE ${identifier_Left_Striosome} ${experimental_directory}/temp_Left_Striosome.${group} > temp.txt
	           mv temp.txt ${experimental_directory}/temp_Left_Striosome.${group}	 
   	           fslmaths temp_proj_seg_thr_1.nii.gz -thr ${working_threshold} -bin ${identifier_Left_Striosome}_CT_LC_Left-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	           mv ${identifier_Left_Striosome}_CT_LC_Left-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
                   break 4
                 elif [[ ${target_volume} -gt  ${threshold_volume} ]]; then
                   echo "     ##     "
                   echo "     ##     "
                   echo "${identifier_Left_Striosome}, Left Striosome, ${group}, has not been solved at a denominator of ${denominator}. Will keep trying"  
                   echo "     ##     "
                   echo "     ##     "
                   echo "  "
	           break 4    
	         fi
               done
             done
           fi
	 done
      done
   done

#
#

#done
#done

################################################################################################

   cd ${experimental_directory}

   for identifier_Left_Matrix in $(cat temp_Left_Matrix.${group} | awk '{print $1}')
      do

      echo -e "Working on $identifier_Left_Matrix Left Matrix - at Denominator = ${denominator}"

      directory=${experimental_directory}/${identifier_Left_Matrix}/${identifier_Left_Matrix}_Diffusion

      cd ${directory}.bedpostX/Left-${region1}_${group}_classification_targets_excludesMidline.length_corrected
  
#mv ${directory}.bedpostX/Left-${region1}_${group}_classification_targets_excludesMidline.length_corrected/*1.5*gz ${directory}.bedpostX/

      rm temp*nii.gz
      fslmaths ${identifier_Left_Matrix}_CT_LC_Left-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz

      cp ${identifier_Left_Matrix}_CT_LC_Left-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      for threshold2 in 9 8 7 6 5 4 3 2 1 0
	do
        for threshold3 in 9 8 7 6 5 4 3 2 1 0
           do

           working_threshold=0.${threshold2}${threshold3}
           target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

           if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	     echo "Using $working_threshold as a threshold yields a mask that is too small"
           
           elif [[ ${target_volume} -ge  ${threshold_volume} ]]; then
             for threshold4 in 9 8 7 6 5 4 3 2 1 0
               do
               for threshold5 in 9 8 7 6 5 4 3 2 1 0
                 do
                 working_threshold=0.${threshold2}${threshold3}${threshold4}${threshold5}

                 target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

echo $target_volume
echo $threshold_volume
echo " "

  	         if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	           echo "Using $working_threshold as a threshold yields a mask that is too small"

	         elif [[ ${target_volume} ==  ${threshold_volume} ]]; then	
#	           echo "${identifier_Left_Matrix} Left Matrix" 			

                   target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}' `
	           echo "The mask threshold for ${identifier_Left_Matrix}, ${group}, Left Matrix is ${working_threshold}, which yields a mask with ${target_volume} voxels."
	           grep -vwE ${identifier_Left_Matrix} ${experimental_directory}/temp_Left_Matrix.${group} > temp.txt
	           mv temp.txt ${experimental_directory}/temp_Left_Matrix.${group}	 
   	           fslmaths temp_proj_seg_thr_1.nii.gz -thr ${working_threshold} -bin ${identifier_Left_Matrix}_CT_LC_Left-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	           mv ${identifier_Left_Matrix}_CT_LC_Left-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
                   break 4
                 elif [[ ${target_volume} -gt  ${threshold_volume} ]]; then
                   echo "     ##     "
                   echo "     ##     "
                   echo "${identifier_Left_Matrix}, Left Matrix, ${group}, has not been solved at a denominator of ${denominator}. Will keep trying"  
                   echo "     ##     "
                   echo "     ##     "
                   echo "  "
	           break 4    
	         fi
               done
             done
           fi
	 done
      done
   done


#######################################################################################

   cd ${experimental_directory}

   for identifier_Right_Matrix in $(cat temp_Right_Matrix.${group} | awk '{print $1}')
      do

      echo -e "Working on $identifier_Right_Matrix, Right Matrix - at Denominator = ${denominator}"
      echo "  "

      directory=${experimental_directory}/${identifier_Right_Matrix}/${identifier_Right_Matrix}_Diffusion

      cd ${directory}.bedpostX/Right-${region1}_${group}_classification_targets_excludesMidline.length_corrected

      rm temp*nii.gz
      fslmaths ${identifier_Right_Matrix}_CT_LC_Right-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz

      cp ${identifier_Right_Matrix}_CT_LC_Right-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      for threshold2 in 9 8 7 6 5 4 3 2 1 0
	do
        for threshold3 in 9 8 7 6 5 4 3 2 1 0
           do

           working_threshold=0.${threshold2}${threshold3}
           target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

           if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	     echo "Using $working_threshold as a threshold yields a mask that is too small"
           
           elif [[ ${target_volume} -ge  ${threshold_volume} ]]; then
             for threshold4 in 9 8 7 6 5 4 3 2 1 0
               do
               for threshold5 in 9 8 7 6 5 4 3 2 1 0
                 do
                 working_threshold=0.${threshold2}${threshold3}${threshold4}${threshold5}

                 target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

echo $target_volume
echo $threshold_volume
echo " "

  	         if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	           echo "Using $working_threshold as a threshold yields a mask that is too small"

	         elif [[ ${target_volume} ==  ${threshold_volume} ]]; then	
	           echo "${identifier_Right_Matrix} Right Matrix" 			

                   target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}' `
	           echo "The mask threshold for ${identifier_Right_Matrix}, ${group}, Right Matrix is ${working_threshold}, which yields a mask with ${target_volume} voxels."
	           grep -vwE ${identifier_Right_Matrix} ${experimental_directory}/temp_Right_Matrix.${group} > temp.txt
	           mv temp.txt ${experimental_directory}/temp_Right_Matrix.${group}	 
   	           fslmaths temp_proj_seg_thr_1.nii.gz -thr ${working_threshold} -bin ${identifier_Right_Matrix}_CT_LC_Right-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	           mv ${identifier_Right_Matrix}_CT_LC_Right-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
                   break 4
                 elif [[ ${target_volume} -gt  ${threshold_volume} ]]; then
                   echo "     ##     "
                   echo "     ##     "
                   echo "${identifier_Right_Matrix}, Right Matrix, ${group}, has not been solved at a denominator of ${denominator}. Will keep trying"  
                   echo "     ##     "
                   echo "     ##     "
                   echo "  "
	           break 4    
	         fi
               done
             done
           fi
	 done
      done
   done


################################################################################################

   cd ${experimental_directory}

   for identifier_Right_Striosome in $(cat temp_Right_Striosome.${group} | awk '{print $1}')
      do

      echo -e "Now working on $identifier_Right_Striosome, Right Striosome - at Denominator = ${denominator}"

      directory=${experimental_directory}/${identifier_Right_Striosome}/${identifier_Right_Striosome}_Diffusion

      cd ${directory}.bedpostX/Right-${region1}_${group}_classification_targets_excludesMidline.length_corrected
  
      rm temp*nii.gz
      fslmaths ${identifier_Right_Striosome}_CT_LC_Right-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz

      cp ${identifier_Right_Striosome}_CT_LC_Right-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      for threshold2 in 9 8 7 6 5 4 3 2 1 0
	do
        for threshold3 in 9 8 7 6 5 4 3 2 1 0
           do

           working_threshold=0.${threshold2}${threshold3}
           target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

           if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	     echo "Using $working_threshold as a threshold yields a mask that is too small"
           
           elif [[ ${target_volume} -ge  ${threshold_volume} ]]; then
             for threshold4 in 9 8 7 6 5 4 3 2 1 0
               do
               for threshold5 in 9 8 7 6 5 4 3 2 1 0
                 do
                 working_threshold=0.${threshold2}${threshold3}${threshold4}${threshold5}

                 target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}'`

echo $target_volume
echo $threshold_volume
echo " "

  	         if [[ ${target_volume} -lt  ${threshold_volume} ]]; then
	           echo "Using $working_threshold as a threshold yields a mask that is too small"

	         elif [[ ${target_volume} ==  ${threshold_volume} ]]; then	
#	           echo "${identifier_Right_Striosome} Right Striosome" 			

                   target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l $working_threshold -V | awk '{print $1}' `
	           echo "The mask threshold for ${identifier_Right_Striosome}, ${group}, Right Striosome is ${working_threshold}, which yields a mask with ${target_volume} voxels."
	           grep -vwE ${identifier_Right_Striosome} ${experimental_directory}/temp_Right_Striosome.${group} > temp.txt
	           mv temp.txt ${experimental_directory}/temp_Right_Striosome.${group}	 
   	           fslmaths temp_proj_seg_thr_1.nii.gz -thr ${working_threshold} -bin ${identifier_Right_Striosome}_CT_LC_Right-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	           mv ${identifier_Right_Striosome}_CT_LC_Right-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
                   break 4
                 elif [[ ${target_volume} -gt  ${threshold_volume} ]]; then
                   echo "     ##     "
                   echo "     ##     "
                   echo "${identifier_Right_Striosome}, Right Striosome, ${group}, has not been solved at a denominator of ${denominator}. Will keep trying"  
                   echo "     ##     "
                   echo "     ##     "
                   echo "  "
	           break 4    
	         fi
               done
             done
           fi
	 done
      done
   done
done


## Adjust your denominator in the fslmaths step above and rerun. Big jumps (doubling +) are OK. 

   cd ${experimental_directory}

   echo "Subjects whose mask files are still too big, and thus need different denominator values, include:"
   cat temp_Right_Matrix.${group} temp_Right_Striosome.${group} temp_Right_Matrix.${group} temp_Right_Striosome.${group}
   echo "  "
   echo "  "
   echo "Subjects that did not have sufficient voxel numbers to pass the first (0.55) threshold include:"
   cat ${experimental_directory}/1.5SDthresh_runs_that_need_attention.${group}



#
#

