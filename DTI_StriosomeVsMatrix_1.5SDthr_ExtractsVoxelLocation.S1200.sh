#/bin/csh -f
# JLW
# 
#
module unload fsl
module load fsl/5.0.11

region1=trStriatum
group=2020.C
experimental_directory=/project/pediatrics/Waugh_lab/shared/HCP/S1200

cd ${experimental_directory}     
rm LocationValues_IndexedStiatalVoxels.txt
      
echo -e "Identifier \t # ID \t Hemisphere \t Compartment \t Extracted From  \t Voxel Index \t N Voxels \t Whole ROI X \t Whole ROI Y \t Whole ROI Z \t X \t Y \t Z" > LocationValues_IndexedStiatalVoxels.${group}.txt	

for ID in `cat Male_Female_Controls_724.txt`
#`grep AS_Control_List.txt | awk '{print $1}' `
do    
   for compartment in Matrix Striosome
   do       
      for hemisphere1 in Left Right
      do         
         for region2 in  trCaudate.Head_Body #trPutamen  		       
         do
     
#            twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
            num_ID=` grep ${ID} ${experimental_directory}/subjectlist.StrioVsMat.Thalamus.txt | awk '{print $2}' `

            cd ${experimental_directory}/${ID}/${ID}_Diffusion.bedpostX
            rm mask_size ${region1}_X ${region1}_Y ${region1}_Z temp temp_ID temp_region
            echo "${ID}" > temp_ID

# Establishes the center point of the larger region, against which subsequent measures will be compared
	    fslstats ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -C | awk '{print $1}' > ${region1}_X
	    fslstats ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -C | awk '{print $2}' > ${region1}_Y
	    fslstats ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -C | awk '{print $3}' > ${region1}_Z
#
	    rm ${compartment}_X ${compartment}_Y ${compartment}_Z temp_region temp_hemisphere temp_compartment

	    echo "${region2}" > temp_region
 	    echo "${hemisphere1}" > temp_hemisphere
	    echo "${compartment}" > temp_compartment	
	    echo "Now processing ${hemisphere1}-${compartment}-like_Ctx_${group}"

# The "index" flag in fslmaths cuts off the inferior-most voxel, or more likely, starts counting at 0 rather than 1. Adding the 
# original mask image to the index file upps the count for each voxel by 1, preventing the loss of this voxel.

	    fslmaths ${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -index -add ${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz indexed.${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz

	    mask_size=`fslstats ${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -V | awk '{print $1}'` 
#
	    while [ "${mask_size}" -gt 1 ] 
            do
	       mask_size_2=`expr "$mask_size" - 2`
	       rm temp_COG temp_N temp_Ncheck

	       temp_Ncheck=`fslstats indexed.${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -k ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -l ${mask_size_2} -u ${mask_size} -V  | awk '{print $1}'` 

               if [ "${temp_Ncheck}" -gt 0 ] 
               then
	          fslstats indexed.${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -k ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -l ${mask_size_2} -u ${mask_size} -C | awk '{print $1}' > ${compartment}_X
	          fslstats indexed.${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -k ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -l ${mask_size_2} -u ${mask_size} -C | awk '{print $2}' > ${compartment}_Y 
	          fslstats indexed.${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -k ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -l ${mask_size_2} -u ${mask_size} -C | awk '{print $3}' > ${compartment}_Z
	          fslstats indexed.${ID}_CT_LC_${hemisphere1}-${region1}_to_${compartment}-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz -k ${ID}_${hemisphere1}-${region2}_bin0.5.nii.gz -l ${mask_size_2} -u ${mask_size} -V  | awk '{print $1}' > temp_Ncheck

# The line immediately above checks that each indexed value has been used only once - that we're testing only one voxel in the COG commands.

	          echo "${mask_size}" > temp_N
	          echo "${num_ID}" > temp_num_ID
 	          paste temp_ID temp_num_ID temp_hemisphere temp_compartment temp_region temp_N temp_Ncheck ${region1}_X ${region1}_Y ${region1}_Z ${compartment}_X ${compartment}_Y ${compartment}_Z >> temp_COG		
	          mask_size=`expr "$mask_size" - 1`
                  cat temp_COG >> ${experimental_directory}/LocationValues_IndexedStiatalVoxels.${group}.txt
               else
                  echo "skipping"
	          mask_size=`expr "$mask_size" - 1`

               fi

	    rm ${region2}_X ${region2}_Y ${region2}_Z temp_num_ID temp_COG temp_N temp_Ncheck

           done
        done
     done
	   
     echo -e "\n \n \n \n \n \n \n" >> ${experimental_directory}/LocationValues_IndexedStiatalVoxels.${group}.txt	  	 
done
     
cat ${experimental_directory}/LocationValues_IndexedStiatalVoxels.${group}.txt 	
done
