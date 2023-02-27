#/bin/csh -f
#
#  This script 1. defines voxels within the striatum as either Striosome-like or Matrix-like using a series of pre-defined groups, 2. uses
#  an ROI that was not included in the group of ROIs used to establish the striatal parcellation to test the premise: does the group of 
#  voxels defined in step 1 behave in a striosome-like or matrix-like manner, based on subsequent connectivity?
#   
#  Note that this script is set up to test Striosome-favoring regions (those with a YEAR.LETTER format).
#  To modify this script to create/test Matrix-favoring reagions, use the text file with a YEAR.NUMBER format and modify the 
#  lines below that start with "set Matrix_1" and "set Striosome_1" to adjust the number of regions included.
#
setenv FSL_DIR /usr/pubsw/packages/fsl/5.0.6
source /usr/local/freesurfer/nmr-stable53-env
foreach experimental_directory (/cluster/ablood/1/DTI_BTX)

    cd ${experimental_directory}
#
    foreach identifier (`cat subjectlist.txt | awk '{print $1}' `) 
       	cd ${experimental_directory}
#
       	set DTI_directory="${experimental_directory}/${identifier}/${identifier}_fsl_dti/dti"
#
# step 13
	foreach hemisphere1 (Left Right)
	   foreach region1 (Striatum)
# 
###  Pulls ROI IDs from previously-established files to make the Parallel Groups - sets up N distinct target masks to determine 
#    striosome vs. matrix through parallel routes, allowing one to use each Group as an argument for including or excluding a 
#    particular voxel from the classification 
#
	  	foreach group (2018.N-1.A2 2018.N-1.B2 2018.N-1.C2 2018.N-1.D2 2018.N-1.E2) 

		   set twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
		   cd ${DTI_directory}.bedpostX

		   rm ${identifier}_CT_LC_${hemisphere1}-*-like_Striatum_${group}_excludesMidline_PT1_87thresh.nii.gz
		   mkdir ${twoROImask}
		   mkdir ${experimental_directory}/Diffusion/ForRandomise/${twoROImask}		
	           rm ${twoROImask}/targets.txt ${twoROImask}/temp2.csh ${twoROImask}/temp3
		   set seed=${identifier}_${hemisphere1}-${region1}_bin0.5.nii.gz
echo "test 3"
		   set Matrix_1=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 1p`
		   set Matrix_2=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 2p`
	 	   set Matrix_3=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 3p`
	 	   set Matrix_4=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 4p`
	 	   set Matrix_5=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $1}' | sed -n 5p`
		   fslmaths ${identifier}_${hemisphere1}-${Matrix_1}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_2}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_3}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_4}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Matrix_5}_bin0.5.nii.gz -bin ${identifier}_${hemisphere1}-Matrix-like_Ctx_${group}_bin0.5.nii.gz

echo "test 4"
#
		   set Striosome_1=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 1p`
		   set Striosome_2=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 2p`
		   set Striosome_3=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 3p`
		   set Striosome_4=`cat /cluster/ablood/1/DTI_BTX/Colocalization/StriosomeVsMatrix.${group}.txt | awk '{print $2}' | sed -n 4p`
		   fslmaths ${identifier}_${hemisphere1}-${Striosome_1}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_2}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_3}_bin0.5.nii.gz -add ${identifier}_${hemisphere1}-${Striosome_4}_bin0.5.nii.gz -bin ${identifier}_${hemisphere1}-Striosome-like_Ctx_${group}_bin0.5.nii.gz
#
###  Adds the primary endpoint for this experiment, the Striosome- or Matrix-like cortex, to the list-file used for targetting.
#
		   foreach region2 (Striosome-like_Ctx_${group} Matrix-like_Ctx_${group})
		      echo "${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz" >> ${twoROImask}/targets.txt
		      echo "mv seeds_to_${identifier}_${hemisphere1}-${region2}_bin0.5.nii.gz ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline.nii.gz" >> ${twoROImask}/temp2.csh

		      echo "applywarp --ref=/cluster/ablood/1/jeff/MasterFiles/FMRIB58_FA_1mm.nii.gz --in=${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz --warp=${DTI_directory}/${identifier}_transtostandard.mat.nii.gz --out=${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz" >> ${twoROImask}/temp3.csh
		      echo "cp ${identifier}_CT_LC_toMNI_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.nii.gz ${experimental_directory}/Diffusion/ForRandomise/${twoROImask}" >> ${twoROImask}/temp3.csh
#
		      echo "fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -thr 0.87 -bin ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.87thresh.nii.gz" >> temp3.csh
		      echo "mv ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1.87thresh.nii.gz ../" >> temp3.csh 
		   end		
                   echo "proj_thresh ${identifier}_CT_LC_${hemisphere1}-${region1}_to_*like_Ctx_${group}_excludesMidline.nii.gz 1" >> ${twoROImask}/temp2.csh

		   echo "fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_proj_seg_thr_1.nii.gz -thr 0.87 -bin ${identifier}_CT_LC_${hemisphere1}-Striosome-like_Striatum_${group}_excludesMidline_PT1_87thresh.nii.gz" >> ${twoROImask}/temp2.csh
		   echo "fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_proj_seg_thr_1.nii.gz -thr 0.87 -bin ${identifier}_CT_LC_${hemisphere1}-Matrix-like_Striatum_${group}_excludesMidline_PT1_87thresh.nii.gz" >> ${twoROImask}/temp2.csh
		
		   echo "mv ${identifier}_CT_LC_${hemisphere1}-*-like_Ctx_${group}_excludesMidline_PT1_87thresh.nii.gz ../" >> ${twoROImask}/temp2.csh
###  Adds the remaining targets to the list-file - in this case, all of the regions that are added to make the 
#    Striosome-like or Matrix-like cortex target masks
		   foreach region3 (trOrbitofrontal_Area13 GyrusRectus trAntCingulate_pregenual Pulvinar CentralAmygdala)
 	              echo "${identifier}_${hemisphere1}-${region3}_bin0.5.nii.gz" >> ${twoROImask}/targets.txt
		   end
#		
### Section below combines with scattered lines above to complete the "Reversed Targets" tractography - using the voxels defined above as 
#   Striosome-like or Matrix-like at targets for tractography with Group-specific ROIs as seeds
#
#
### Adds probtrackx2 runs to file for launchpad submission, Reversed Targets
#
		    end	
#
		    rm temp1
		    echo "#\!/bin/tcsh \n# \n#" >> temp1
		    echo "probtrackx2 --seed=${seed} -l --loopcheck --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --forcedir --opd --samples=merged --avoid=${identifier}_MidlinePlane.FA_bin0.5.nii.gz --mask=nodif_brain_mask --dir=${DTI_directory}.bedpostX/${twoROImask} --targetmasks=${twoROImask}/targets.txt --os2t --pd --out=${identifier}_ptracx_${twoROImask}.nii.gz" >> temp1
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


