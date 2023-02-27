#/bin/csh -f
#  
#  This script aims to equalize the numbers of voxels in a striosome-like or matrix-like striatal mask. It eliminates the middle 
#  3 Standard Deviations (1.5 SD above and below the mean, hence 1.5SD in the final mask file name), assuring that only the uppermost ~76 voxels of the striatum are kept.
#  This makes it less likely that a subject's striatum dominated by one compartment will "win all" and thus misattribute the 
#  parcellated striatal voxels.
#  Empirically, setting the target_threshold a little below the desired voxel number will yield approximately your target. This is why
#  v1.0 starts with a target_threshold of 75, hoping for a final mask size of 76-77.
#
#
setenv FSL_DIR /usr/pubsw/packages/fsl/5.0.6
source /usr/local/freesurfer/nmr-stable53-env

foreach experimental_directory (/cluster/ablood/2/XDP_Transfer)
    cd ${experimental_directory}
    rm 1.5SDthresh_runs_that_need_attention 1.5SDthresh_runs_that_are_too_big
#
    foreach group (2018.C)
# 2018.N-1.A2 2018.N-1.B2 2018.N-1.C 2018.N-1.D2 2018.N-1.E2  2018.N-1.12  2018.N-1.22 2018.N-1.32 2018.N-1.42 2018.N-1.52)
    foreach identifier (`awk '{print $1}' subjectlist.txt `)
#
# Pulls subject identifier from pre-made list in the experimental directory.  To set up directory structures as FSL needs, this is done in two steps: 
# first for patients, then for controls. Then copies all DTI directories from UnpackedData to the experimental directory for each subject.
	echo "Now processing ${identifier}"
#
	set DTI_directory="${experimental_directory}/${identifier}/${identifier}_fsl_dti/dti"
	set region1=Striatum		       
	foreach hemisphere1 (Left Right)
           set twoROImask=${hemisphere1}-${region1}_${group}_classification_targets_excludesMidline.length_corrected
	   foreach region2 (Striosome-like_Ctx_${group} Matrix-like_Ctx_${group})
	      echo "Now processing ${hemisphere1}-${region2}"
	      set threshold_volume=75	  
#
##   The line below writes the subject name and hemisphere-region into a text file. If the subject's mask file is big enough to pash threshold (entering the loop below), then this
#    line is removed. If it's not removed, then at the end of the script this file will be read out as subjects needing manual attention.
              echo "${identifier}_${hemisphere1}-${region1}_to_${region2}.${group}" >> ${experimental_directory}/1.5SDthresh_runs_that_need_attention
#
 	      foreach threshold (0.9999999 0.9999998 0.9999997 0.9999996 0.9999995 0.9999994 0.9999993 0.9999992 0.9999991 0.999999 0.999998  0.999997 0.999996 0.999995 0.999994 0.999993 0.999992 0.999991 0.99999 0.99995 0.9999 0.9995 0.999 0.9975 0.995 0.9925 0.99 0.989 0.988 0.987 0.986 0.985 0.984 0.983 0.982 0.981 0.98 0.979 0.978 0.977 0.976 0.975 0.974 0.973 0.972 0.971 0.97 0.969 0.968 0.967 0.966 0.965 0.964 0.963 0.962 0.961 0.96 0.959 0.958 0.957 0.956 0.955 0.954 0.953 0.952 0.951 0.95 0.949 0.948 0.947 0.946 0.945 0.944 0.943 0.942 0.941 0.94 0.939 0.938 0.937 0.936 0.935 0.934 0.933 0.932 0.931 0.93 0.929 0.928 0.927 0.926 0.925 0.924 0.923 0.922 0.921 0.92 0.919 0.918 0.917 0.916 0.915 0.914 0.913 0.912 0.911 0.91 0.909 0.908 0.907 0.906 0.905 0.904 0.903 0.902 0.901 0.9 0.899 0.898 0.897 0.896 0.895 0.894 0.893 0.892 0.891 0.89 0.889 0.888 0.887 0.886 0.885 0.884 0.883 0.882 0.881 0.88 0.879 0.878 0.877 0.876 0.875 0.874 0.873 0.872 0.871 0.87 0.869 0.868 0.867 0.866 0.865 0.864 0.863 0.862 0.861 0.86 0.859 0.858 0.857 0.856 0.855 0.854 0.853 0.852 0.851 0.85 0.849 0.848 0.847 0.846 0.845 0.844 0.843 0.842 0.841 0.84 0.839 0.838 0.837 0.836 0.835 0.834 0.833 0.832 0.831 0.83 0.829 0.828 0.827 0.826 0.825 0.824 0.823 0.822 0.821 0.82 0.819 0.818 0.817 0.816 0.815 0.814 0.813 0.812 0.811 0.81 0.809 0.808 0.807 0.806 0.805 0.804 0.803 0.802 0.801 0.8 0.799 0.798 0.797 0.796 0.795 0.794 0.793 0.792 0.791 0.79 0.789 0.788 0.787 0.786 0.785 0.784 0.783 0.782 0.781 0.78 0.779 0.778 0.777 0.776 0.775 0.774 0.773 0.772 0.771 0.77 0.769 0.768 0.767 0.766 0.765 0.764 0.763 0.762 0.761 0.76 0.759 0.758 0.757 0.756 0.755 0.754 0.753 0.752 0.751 0.75 0.749 0.748 0.747 0.746 0.745 0.744 0.743 0.742 0.741 0.74 0.739 0.738 0.737 0.736 0.735 0.734 0.733 0.732 0.731 0.73 0.729 0.728 0.727 0.726 0.725 0.724 0.723 0.722 0.721 0.72 0.719 0.718 0.717 0.716 0.715 0.714 0.713 0.712 0.711 0.71 0.709 0.708 0.707 0.706 0.705 0.704 0.703 0.702 0.701 0.7 0.699 0.698 0.697 0.696 0.695 0.694 0.693 0.692 0.691 0.69 0.689 0.688 0.687 0.686 0.685 0.684 0.683 0.682 0.681 0.68 0.679 0.678 0.677 0.676 0.675 0.674 0.673 0.672 0.671 0.67 0.669 0.668 0.667 0.666 0.665 0.664 0.663 0.662 0.661 0.66 0.659 0.658 0.657 0.656 0.655 0.654 0.653 0.652 0.651 0.65 0.649 0.648 0.647 0.646 0.645 0.644 0.643 0.642 0.641 0.64 0.639 0.638 0.637 0.636 0.635 0.634 0.633 0.632 0.631 0.63 0.629 0.628 0.627 0.626 0.625 0.624 0.623 0.622 0.621 0.62 0.619 0.618 0.617 0.616 0.615 0.614 0.613 0.612 0.611 0.61 0.609 0.608 0.607 0.606 0.605 0.604 0.603 0.602 0.601 0.6 0.599 0.598 0.597 0.596 0.595 0.594 0.593 0.592 0.591 0.59 0.589 0.588 0.587 0.586 0.585 0.584 0.583 0.582 0.581 0.58 0.579 0.578 0.577 0.576 0.575 0.574 0.573 0.572 0.571 0.57 0.569 0.568 0.567 0.566 0.565 0.564 0.563 0.562 0.561 0.56 0.559 0.558 0.557 0.556 0.555 0.554 0.553 0.552 0.551 0.55) 
  	         cd ${DTI_directory}.bedpostX/${twoROImask}	
                 set target_volume=`fslstats ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -l ${threshold} -V | awk '{print $1}' `
   	         if (("${target_volume}" <=  "${threshold_volume}")) then
	   	    echo "Using ${threshold} as a threshold yields a mask that is too small"
   		    fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -thr 0.55 -bin ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1_1.5SDthresh.nii.gz
	         else 
	         echo "The mask threshold for ${identifier}, ${region2} is ${threshold}, which yields a mask with ${target_volume} voxels."
#
	         grep -vwE ${identifier}_${hemisphere1}-${region1}_to_${region2}.${group} ${experimental_directory}/1.5SDthresh_runs_that_need_attention > temp
	         mv temp ${experimental_directory}/1.5SDthresh_runs_that_need_attention
     	         fslmaths ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_proj_seg_thr_1.nii.gz -thr ${threshold} -bin ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1_1.5SDthresh.nii.gz
	         mv ${identifier}_CT_LC_${hemisphere1}-${region1}_to_${region2}_excludesMidline_PT1_1.5SDthresh.nii.gz ../	
	         cd ${experimental_directory}
      	         break
	         endif
	      end
#
		 if (("${target_volume}" >=  "77")) then
		    echo "${identifier} ${hemisphere1}-${region1}_to_${region2} yielded a mask of ${target_volume}." >> ${experimental_directory}/1.5SDthresh_runs_that_are_too_big 	
		 endif
	   end
       end
    end
end
#
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
foreach denominator (500 2 5 25 75 250 500 750 1250 1500 2000 25000 2300 2600 2900 4000 5000 6000 8000 15000 20000 30000 32000 34000 36000 38000 40000 60000 70000 80000 85000 90000 95000 100000 105000 110000 120000 150000 200000 300000 400000 500000 600000 700000)
   cd ${experimental_directory}
   rm temp_Left_Matrix temp_Left_Striosome temp_Right_Matrix temp_Right_Striosome temp still_too_big
   grep Left 1.5SDthresh_runs_that_are_too_big | grep Matrix > temp_Left_Matrix
   grep Left 1.5SDthresh_runs_that_are_too_big | grep Striosome > temp_Left_Striosome
   grep Right 1.5SDthresh_runs_that_are_too_big | grep Matrix > temp_Right_Matrix
   grep Right 1.5SDthresh_runs_that_are_too_big | grep Striosome > temp_Right_Striosome

   echo " ####### "
   echo " ####### "
   echo " ####### "
   echo "Now utilizing ___${denominator}___ as the denominator."
   echo " ####### "
   echo " ####### "
   echo " ####### "

   foreach identifier_Left_Matrix (`cat temp_Left_Matrix | awk '{print $1}' `)
      cd ${experimental_directory}/${identifier_Left_Matrix}/${identifier_Left_Matrix}_fsl_dti/dti*X/Left-Striatum_${group}_classification_targets_excludesMidline.length_corrected
      rm temp*nii.gz
      fslmaths ${identifier_Left_Matrix}_CT_LC_Left-Striatum_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz
      cp ${identifier_Left_Matrix}_CT_LC_Left-Striatum_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      foreach threshold2 (0.9999999 0.9999998 0.9999997 0.9999996 0.9999995 0.9999994 0.9999993 0.9999992 0.9999991 0.999999 0.999998 0.999997 0.999996 0.999995 0.999994 0.999993 0.999992 0.999991 0.99999 0.9999 0.999 0.9975 0.995 0.9925 0.99 0.985 0.98 0.975 0.97 0.965 0.96 0.955 0.95 0.945 0.94 0.935 0.93 0.925 0.92 0.915 0.91 0.905 0.9 0.895 0.89 0.885 0.88 0.875 0.87 0.865 0.86 0.855 0.85 0.845 0.84 0.835 0.83 0.825 0.82 0.815 0.81 0.805 0.8 0.795 0.79 0.785 0.78 0.775 0.77 0.765 0.76 0.755 0.75 0.745 0.74 0.735 0.73 0.725 0.72 0.715 0.71 0.705 0.7 0.695 0.69 0.685 0.68 0.675 0.67 0.665 0.66 0.655 0.65 0.645 0.64 0.635 0.63 0.625 0.62 0.615 0.61 0.605 0.6 0.595 0.59 0.585 0.58 0.575 0.57 0.565 0.56 0.555 0.55 0.545 0.54 0.535 0.53 0.525 0.52 0.515 0.51 0.505 0.5 0.495 0.49 0.485 0.48 0.475 0.47 0.465 0.46 0.455 0.45 0.445 0.44 0.435 0.43 0.425 0.42 0.415 0.41 0.405 0.4 0.395 0.39 0.385 0.38 0.375 0.37 0.365 0.36 0.355 0.35 0.345 0.34 0.335 0.33 0.325 0.32 0.315 0.31 0.305 0.3 0.295 0.29 0.285 0.28 0.275 0.27 0.265 0.26 0.255 0.25 0.245 0.24 0.235 0.23 0.225 0.22 0.215 0.21 0.205 0.2 0.195 0.19 0.185 0.18 0.175 0.17 0.165 0.16 0.155 0.15 0.145 0.14 0.135 0.13 0.125 0.12 0.115 0.11 0.105 0.1 0.099 0.098 0.097 0.096 0.095 0.094 0.093 0.092 0.091 0.09 0.089 0.088 0.087 0.086 0.085 0.084 0.083 0.082 0.081 0.08 0.079 0.078 0.077 0.076 0.075 0.074 0.073 0.072 0.071 0.07 0.069 0.068 0.067 0.066 0.065 0.064 0.063 0.062 0.061 0.06 0.059 0.058 0.057 0.056 0.055 0.054 0.053 0.052 0.051 0.05 0.049 0.048 0.047 0.046 0.045 0.044 0.043 0.042 0.041 0.04 0.039 0.038 0.037 0.036 0.035 0.034 0.033 0.032 0.031 0.03 0.029 0.028 0.027 0.026 0.025 0.024 0.023 0.022 0.021 0.02 0.019 0.018 0.017 0.016 0.015 0.014 0.013 0.012 0.011 0.01 0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001) 
         set target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l ${threshold2} -V | awk '{print $1}' `
   	 if (("${target_volume}" <=  "${threshold_volume}")) then
	    echo "Using ${threshold2} as a threshold yields a mask that is too small"
         else 
	    if (("${target_volume}" >=  "77")) then	
	       echo "${identifier_Left_Matrix} Left Matrix" >> ${experimental_directory}/still_too_big			
   	    endif
	    echo "The mask threshold for ${identifier_Left_Matrix}, ${group}, Left Matrix is ${threshold2}, which yields a mask with ${target_volume} voxels."
	    grep -vwE ${identifier_Left_Matrix} temp_Left_Matrix > temp
	    mv temp ${experimental_directory}/temp_Left_Matrix
#	 
   	    fslmaths temp_proj_seg_thr_1.nii.gz -thr ${threshold2} -bin ${identifier_Left_Matrix}_CT_LC_Left-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	    mv ${identifier_Left_Matrix}_CT_LC_Left-${region1}_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
            break
         endif
      end 	
   end
   cd ${experimental_directory}
#
#
   foreach identifier_Left_Striosome (`cat temp_Left_Striosome | awk '{print $1}' `)
      cd ${experimental_directory}/${identifier_Left_Striosome}/${identifier_Left_Striosome}_fsl_dti/dti*X/Left-Striatum_${group}_classification_targets_excludesMidline.length_corrected
      rm temp*nii.gz
      fslmaths ${identifier_Left_Striosome}_CT_LC_Left-Striatum_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz
      cp ${identifier_Left_Striosome}_CT_LC_Left-Striatum_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      foreach threshold3 (0.9999999 0.9999998 0.9999997 0.9999996 0.9999995 0.9999994 0.9999993 0.9999992 0.9999991 0.999999 0.999998 0.999997 0.999996 0.999995 0.999994 0.999993 0.999992 0.999991 0.99999 0.9999 0.999 0.9975 0.995 0.9925 0.99 0.985 0.98 0.975 0.97 0.965 0.96 0.955 0.95 0.945 0.94 0.935 0.93 0.925 0.92 0.915 0.91 0.905 0.9 0.895 0.89 0.885 0.88 0.875 0.87 0.865 0.86 0.855 0.85 0.845 0.84 0.835 0.83 0.825 0.82 0.815 0.81 0.805 0.8 0.795 0.79 0.785 0.78 0.775 0.77 0.765 0.76 0.755 0.75 0.745 0.74 0.735 0.73 0.725 0.72 0.715 0.71 0.705 0.7 0.695 0.69 0.685 0.68 0.675 0.67 0.665 0.66 0.655 0.65 0.645 0.64 0.635 0.63 0.625 0.62 0.615 0.61 0.605 0.6 0.595 0.59 0.585 0.58 0.575 0.57 0.565 0.56 0.555 0.55 0.545 0.54 0.535 0.53 0.525 0.52 0.515 0.51 0.505 0.5 0.495 0.49 0.485 0.48 0.475 0.47 0.465 0.46 0.455 0.45 0.445 0.44 0.435 0.43 0.425 0.42 0.415 0.41 0.405 0.4 0.395 0.39 0.385 0.38 0.375 0.37 0.365 0.36 0.355 0.35 0.345 0.34 0.335 0.33 0.325 0.32 0.315 0.31 0.305 0.3 0.295 0.29 0.285 0.28 0.275 0.27 0.265 0.26 0.255 0.25 0.245 0.24 0.235 0.23 0.225 0.22 0.215 0.21 0.205 0.2 0.195 0.19 0.185 0.18 0.175 0.17 0.165 0.16 0.155 0.15 0.145 0.14 0.135 0.13 0.125 0.12 0.115 0.11 0.105 0.1 0.099 0.098 0.097 0.096 0.095 0.094 0.093 0.092 0.091 0.09 0.089 0.088 0.087 0.086 0.085 0.084 0.083 0.082 0.081 0.08 0.079 0.078 0.077 0.076 0.075 0.074 0.073 0.072 0.071 0.07 0.069 0.068 0.067 0.066 0.065 0.064 0.063 0.062 0.061 0.06 0.059 0.058 0.057 0.056 0.055 0.054 0.053 0.052 0.051 0.05 0.049 0.048 0.047 0.046 0.045 0.044 0.043 0.042 0.041 0.04 0.039 0.038 0.037 0.036 0.035 0.034 0.033 0.032 0.031 0.03 0.029 0.028 0.027 0.026 0.025 0.024 0.023 0.022 0.021 0.02 0.019 0.018 0.017 0.016 0.015 0.014 0.013 0.012 0.011 0.01 0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001) 
         set target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l ${threshold3} -V | awk '{print $1}' `
   	 if (("${target_volume}" <=  "${threshold_volume}")) then
	    echo "Using ${threshold3} as a threshold yields a mask that is too small"
         else 
	    if (("${target_volume}" >=  "77")) then	
	       echo "${identifier_Left_Striosome} Left Striosome" >> ${experimental_directory}/still_too_big			
   	    endif
	    echo "The mask threshold for ${identifier_Left_Striosome}, ${group}, Left Striosome is ${threshold3}, which yields a mask with ${target_volume} voxels."
	    grep -vwE ${identifier_Left_Striosome} temp_Left_Striosome > temp
	    mv temp ${experimental_directory}/temp_Left_Striosome
#	 
   	    fslmaths temp_proj_seg_thr_1.nii.gz -thr ${threshold3} -bin ${identifier_Left_Striosome}_CT_LC_Left-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	    mv ${identifier_Left_Striosome}_CT_LC_Left-${region1}_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
            break
         endif
      end 	
   end
   cd ${experimental_directory}
#
#
   foreach identifier_Right_Matrix (`cat temp_Right_Matrix | awk '{print $1}' `)
      cd ${experimental_directory}/${identifier_Right_Matrix}/${identifier_Right_Matrix}_fsl_dti/dti*X/Right-Striatum_${group}_classification_targets_excludesMidline.length_corrected
      rm temp*nii.gz
      fslmaths ${identifier_Right_Matrix}_CT_LC_Right-Striatum_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz
      cp ${identifier_Right_Matrix}_CT_LC_Right-Striatum_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      foreach threshold4 (0.9999999 0.9999998 0.9999997 0.9999996 0.9999995 0.9999994 0.9999993 0.9999992 0.9999991 0.999999 0.999998 0.999997 0.999996 0.999995 0.999994 0.999993 0.999992 0.999991 0.99999 0.9999 0.999 0.9975 0.995 0.9925 0.99 0.985 0.98 0.975 0.97 0.965 0.96 0.955 0.95 0.945 0.94 0.935 0.93 0.925 0.92 0.915 0.91 0.905 0.9 0.895 0.89 0.885 0.88 0.875 0.87 0.865 0.86 0.855 0.85 0.845 0.84 0.835 0.83 0.825 0.82 0.815 0.81 0.805 0.8 0.795 0.79 0.785 0.78 0.775 0.77 0.765 0.76 0.755 0.75 0.745 0.74 0.735 0.73 0.725 0.72 0.715 0.71 0.705 0.7 0.695 0.69 0.685 0.68 0.675 0.67 0.665 0.66 0.655 0.65 0.645 0.64 0.635 0.63 0.625 0.62 0.615 0.61 0.605 0.6 0.595 0.59 0.585 0.58 0.575 0.57 0.565 0.56 0.555 0.55 0.545 0.54 0.535 0.53 0.525 0.52 0.515 0.51 0.505 0.5 0.495 0.49 0.485 0.48 0.475 0.47 0.465 0.46 0.455 0.45 0.445 0.44 0.435 0.43 0.425 0.42 0.415 0.41 0.405 0.4 0.395 0.39 0.385 0.38 0.375 0.37 0.365 0.36 0.355 0.35 0.345 0.34 0.335 0.33 0.325 0.32 0.315 0.31 0.305 0.3 0.295 0.29 0.285 0.28 0.275 0.27 0.265 0.26 0.255 0.25 0.245 0.24 0.235 0.23 0.225 0.22 0.215 0.21 0.205 0.2 0.195 0.19 0.185 0.18 0.175 0.17 0.165 0.16 0.155 0.15 0.145 0.14 0.135 0.13 0.125 0.12 0.115 0.11 0.105 0.1 0.099 0.098 0.097 0.096 0.095 0.094 0.093 0.092 0.091 0.09 0.089 0.088 0.087 0.086 0.085 0.084 0.083 0.082 0.081 0.08 0.079 0.078 0.077 0.076 0.075 0.074 0.073 0.072 0.071 0.07 0.069 0.068 0.067 0.066 0.065 0.064 0.063 0.062 0.061 0.06 0.059 0.058 0.057 0.056 0.055 0.054 0.053 0.052 0.051 0.05 0.049 0.048 0.047 0.046 0.045 0.044 0.043 0.042 0.041 0.04 0.039 0.038 0.037 0.036 0.035 0.034 0.033 0.032 0.031 0.03 0.029 0.028 0.027 0.026 0.025 0.024 0.023 0.022 0.021 0.02 0.019 0.018 0.017 0.016 0.015 0.014 0.013 0.012 0.011 0.01 0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001) 
         set target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l ${threshold4} -V | awk '{print $1}' `
   	 if (("${target_volume}" <=  "${threshold_volume}")) then
	    echo "Using ${threshold4} as a threshold yields a mask that is too small"
         else 
	    if (("${target_volume}" >=  "77")) then	
	       echo "${identifier_Right_Matrix} Right Matrix" >> ${experimental_directory}/still_too_big			
   	    endif
	    echo "The mask threshold for ${identifier_Right_Matrix}, ${group}, Right Matrix is ${threshold4}, which yields a mask with ${target_volume} voxels."
	    grep -vwE ${identifier_Right_Matrix} temp_Right_Matrix > temp
	    mv temp ${experimental_directory}/temp_Right_Matrix
#	 
   	    fslmaths temp_proj_seg_thr_1.nii.gz -thr ${threshold4} -bin ${identifier_Right_Matrix}_CT_LC_Right-Striatum_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	    mv ${identifier_Right_Matrix}_CT_LC_Right-Striatum_to_Matrix-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
            break
         endif
      end 	
   end
   cd ${experimental_directory}
#
#
   foreach identifier_Right_Striosome (`cat temp_Right_Striosome | awk '{print $1}' `)
      cd ${experimental_directory}/${identifier_Right_Striosome}/${identifier_Right_Striosome}_fsl_dti/dti*X/Right-Striatum_${group}_classification_targets_excludesMidline.length_corrected
      rm temp*nii.gz
      fslmaths ${identifier_Right_Striosome}_CT_LC_Right-Striatum_to_Striosome-like_Ctx_${group}_excludesMidline.nii.gz -div ${denominator} temp.nii.gz
      cp ${identifier_Right_Striosome}_CT_LC_Right-Striatum_to_Matrix-like_Ctx_${group}_excludesMidline.nii.gz temp2.nii.gz
      proj_thresh temp.nii.gz temp2.nii.gz 1	
#
      foreach threshold5 (0.9999999 0.9999998 0.9999997 0.9999996 0.9999995 0.9999994 0.9999993 0.9999992 0.9999991 0.999999 0.999998 0.999997 0.999996 0.999995 0.999994 0.999993 0.999992 0.999991 0.99999 0.9999 0.999 0.9975 0.995 0.9925 0.99 0.985 0.98 0.975 0.97 0.965 0.96 0.955 0.95 0.945 0.94 0.935 0.93 0.925 0.92 0.915 0.91 0.905 0.9 0.895 0.89 0.885 0.88 0.875 0.87 0.865 0.86 0.855 0.85 0.845 0.84 0.835 0.83 0.825 0.82 0.815 0.81 0.805 0.8 0.795 0.79 0.785 0.78 0.775 0.77 0.765 0.76 0.755 0.75 0.745 0.74 0.735 0.73 0.725 0.72 0.715 0.71 0.705 0.7 0.695 0.69 0.685 0.68 0.675 0.67 0.665 0.66 0.655 0.65 0.645 0.64 0.635 0.63 0.625 0.62 0.615 0.61 0.605 0.6 0.595 0.59 0.585 0.58 0.575 0.57 0.565 0.56 0.555 0.55 0.545 0.54 0.535 0.53 0.525 0.52 0.515 0.51 0.505 0.5 0.495 0.49 0.485 0.48 0.475 0.47 0.465 0.46 0.455 0.45 0.445 0.44 0.435 0.43 0.425 0.42 0.415 0.41 0.405 0.4 0.395 0.39 0.385 0.38 0.375 0.37 0.365 0.36 0.355 0.35 0.345 0.34 0.335 0.33 0.325 0.32 0.315 0.31 0.305 0.3 0.295 0.29 0.285 0.28 0.275 0.27 0.265 0.26 0.255 0.25 0.245 0.24 0.235 0.23 0.225 0.22 0.215 0.21 0.205 0.2 0.195 0.19 0.185 0.18 0.175 0.17 0.165 0.16 0.155 0.15 0.145 0.14 0.135 0.13 0.125 0.12 0.115 0.11 0.105 0.1 0.099 0.098 0.097 0.096 0.095 0.094 0.093 0.092 0.091 0.09 0.089 0.088 0.087 0.086 0.085 0.084 0.083 0.082 0.081 0.08 0.079 0.078 0.077 0.076 0.075 0.074 0.073 0.072 0.071 0.07 0.069 0.068 0.067 0.066 0.065 0.064 0.063 0.062 0.061 0.06 0.059 0.058 0.057 0.056 0.055 0.054 0.053 0.052 0.051 0.05 0.049 0.048 0.047 0.046 0.045 0.044 0.043 0.042 0.041 0.04 0.039 0.038 0.037 0.036 0.035 0.034 0.033 0.032 0.031 0.03 0.029 0.028 0.027 0.026 0.025 0.024 0.023 0.022 0.021 0.02 0.019 0.018 0.017 0.016 0.015 0.014 0.013 0.012 0.011 0.01 0.009 0.008 0.007 0.006 0.005 0.004 0.003 0.002 0.001) 
         set target_volume=`fslstats temp_proj_seg_thr_1.nii.gz -l ${threshold5} -V | awk '{print $1}' `
   	 if (("${target_volume}" <=  "${threshold_volume}")) then
	    echo "Using ${threshold5} as a threshold yields a mask that is too small"
         else 
	    if (("${target_volume}" >=  "77")) then	
	       echo "${identifier_Right_Striosome} Right Striosome" >> ${experimental_directory}/still_too_big			
   	    endif
	    echo "The mask threshold for ${identifier_Right_Striosome}, ${group}, Right Striosome is ${threshold5}, which yields a mask with ${target_volume} voxels."
	    grep -vwE ${identifier_Right_Striosome} temp_Right_Striosome > temp
	    mv temp ${experimental_directory}/temp_Right_Striosome
#	 
   	    fslmaths temp_proj_seg_thr_1.nii.gz -thr ${threshold5} -bin ${identifier_Right_Striosome}_CT_LC_Right-Striatum_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz
	    mv ${identifier_Right_Striosome}_CT_LC_Right-Striatum_to_Striosome-like_Ctx_${group}_excludesMidline_PT1_1.5SDthresh.nii.gz ../
            break
         endif
      end 	
   end
   cd ${experimental_directory}
   cp still_too_big 1.5SDthresh_runs_that_are_too_big
## Adjust your denominator in the fslmaths step above and rerun. Big jumps (doubling +) are OK. 
   echo "Subjects not solved by script above include:"
   cat temp_Left_Matrix temp_Left_Striosome temp_Right_Matrix temp_Right_Striosome temp
#
#

end
end
