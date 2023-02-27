#/bin/csh -f
#
#  This script defines each voxel within the target region based on its probability of structural connection to either
#  Matrix-favoring or Striosome-favoring targets (as defined by prior tract-tracing studies in animals) using "classification
#  targets" mode in the FSL tool probtrackx. As written, the script extracts subject identifiers from a separate text file 
#  (subjectlist.txt) and Matrix- and Striosome-favoring regions from the separate text file, StriosomeVsMatrix.YEAR.LETTER.txt.
#  YEAR and LETTER have no special significance - this is just the year they were created and the iteration in the series.
#
#  As written the script submits the full job to our shared cluster, launchpad. Adapt this to run locally or for submission to your 
#  own cluster environment.
#
#  The output of this script will be native-space probability maps of connectivity between each striatal voxel and the summed 
#  target volumes. While the raw probability maps are useful to demonstrate the distribution of striosome-like and matrix-like 
#  voxels, if you want to quantify connectivity you will likely want to use the next Linux script in this series, which creates
#  equal-sized striatal masks of each probability distribution: DTI_StriosomeVsMatrix_CreatesEqual-sizedStriatalMasks_1.5SD.NI.csh
#  

source /usr/local/freesurfer/nmr-stable53-env
    
set group=2018.C

foreach experimental_directory (/cluster/ablood/1/DTI_BTX /cluster/ablood/1/DTI_BTX/Colocalization)

    cd ${experimental_directory}
#
    foreach identifier (`awk '{print $1}' subjectlist.txt `) 

       cd ${experimental_directory}
       set subject_type=`grep ${identifier} subjectlist.txt | sed 's/series //g' | awk '{print $3}' | sed -n 1p`
       set directory_name=${subject_type}_`grep ${identifier} subjectlist.txt | sed 's/series //g' | awk '{print $1}' | sed -n 1p`
       set DTI1=`grep ${identifier} subjectlist.txt | sed 's/series //g' | awk '{print $2}' | sed -n 1p `
       set DTI_directory="${experimental_directory}/${directory_name}/${identifier}_fsl_dti/dti/${DTI1}"
       echo "Now processing ${identifier}"

#
	    foreach hemisphere1 (Left Right)
	        foreach region1 (Striatum)
# 
###  Pulls ROI IDs from previously-established files to make the Parallel Groups - sets up N distinct target masks to determine 
#    striosome vs. matrix through parallel routes, allowing one to use each Group as an argument for including or excluding a 
#    particular voxel from the classification 
#

		       set twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
		       cd ${DTI_directory}.bedpostX
		       rm ${subject_type}_${identifier}_CT_LC_${hemisphere1}-*-like_Striatum_${group}_excludesMidline_PT1_75thresh.nii.gz
		       rm ${subject_type}_${identifier}_CT_LC_${hemisphere1}-*-like_Striatum_${group}_excludesMidline_PT1_87thresh.nii.gz

		       mkdir ${twoROImask}
		       mkdir ${experimental_directory}/ForRandomise/${twoROImask}		
	               rm ${twoROImask}/targets.txt ${twoROImask}/temp2.csh ${twoROImask}/temp3
		       set seed=${identifier}_${hemisphere1}-${region1}_bin0.5.nii.gz

     		       echo "Processing Matrix-favoring volumes for ${identifier}
		       set Matrix_1=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 1p`
		       set Matrix_2=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 2p`
	 	       set Matrix_3=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 3p`
	 	       set Matrix_4=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 4p`
	 	       set Matrix_5=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 5p`
		       fslmaths ${identifier}_${hemisphere1}-${Matrix_1}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_2}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_3}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_4}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_5}_bin0.5.nii.gz -bin ${identifier}_${hemisphere1}-Matrix-like_Ctx_${group}_bin0.5.nii.gz

		       echo "Processing Striosome-favoring volumes for ${identifier}
		       set Striosome_1=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 1p`
		       set Striosome_2=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 2p`
		       set Striosome_3=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 3p`
		       set Striosome_4=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 4p`
		       set Striosome_5=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 5p`
		       fslmaths ${identifier}_${hemisphere1}-${Striosome_1}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_2}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_3}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_4}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_5}_bin0.5.nii.gz -bin ${identifier}_${hemisphere1}-Striosome-like_Ctx_${group}_bin0.5.nii.gz

### Adds the primary endpoint for this experiment, the Striosome- or Matrix-like cortex, to the list-file used for targetting. #
		       foreach region2 (Striosome-like_Ctx_${group} Matrix-like_Ctx_${group} `awk '{print $1}'  /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt` `awk '{print $2}' /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt` )
		          echo "${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz" >> ${twoROImask}/targets.txt
			  echo "mv seeds_to_${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz ${subject_type}_${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline.nii.gz" >> ${twoROImask}/temp2.csh

		          echo "applywarp --ref=/cluster/ablood/1/jeff/MasterFiles/FMRIB58_FA_1mm.nii.gz --in=${subject_type}_${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz --warp=${DTI_directory}/${subject_type}_${identifier}_transtostandard.mat.nii.gz --out=${subject_type}_${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz" >> ${twoROImask}/temp3.csh
		          echo "cp ${subject_type}_${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz /cluster/ablood/1/DTI_BTX/Colocalization/ForRandomise/${twoROImask}" >> ${twoROImask}/temp3.csh
		       end		
                       echo "proj_thresh ${subject_type}_${identifier}_CT_LC_${hemisphere1}-${region1}_to_*like_Ctx_${group}_excludesMidline.nii.gz 1" >> ${twoROImask}/temp2.csh

#		
		    rm temp1
		    echo "#\!/bin/tcsh \n# \n#" >> temp1
		    echo "probtrackx2 --seed=${seed} -l --loopcheck --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd --samples=merged --avoid=${identifier}_MidlinePlane.FA_bin0.5.nii.gz --mask=${DTI_directory}/nodif_brain_mask --dir=${DTI_directory}.bedpostX/${twoROImask} --targetmasks=${twoROImask}/targets.txt --os2t --pd --out=${subject_type}_${identifier}_ptracx_${twoROImask}.nii.gz" >> temp1
		    echo "cd ${DTI_directory}.bedpostX/${twoROImask}" >> temp1
		    echo "csh temp2.csh" >> temp1
		    echo "csh temp3.csh" >> temp1
		    mv temp1 temp_ptracx_${identifier}_${twoROImask}.csh
		    pbsubmit -q max200 -c "csh temp_ptracx_${identifier}_${twoROImask}.csh"
#	   
	end
    end
end
end
end
end
end

