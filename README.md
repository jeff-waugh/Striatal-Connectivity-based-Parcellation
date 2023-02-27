# Striatal-Connectivity-based-Parcellation

With the ROI masks and Linux scripts included here, you can generate connectivity-based parcellations of the human striatum. The striatum is comprised
of two tissue compartments, the striosome and matrix, that are interdigitated and indistinguishable by routine histology or MRI. However, the 
two compartments have markedly different patterns of connectivity - demonstrated through 40+ years of animal studies that used injected tract tracers.

This method uses the differential connectivity demonstrated in prior animal studies to parcellate the striatum into striosome-like and matrix-like 
voxels. While these are NOT the same thing as identifying striosome and matrix (hence the "-like" designation), identifying voxels by their differential
connectivity replicates many of the structural features of striosome and matrix in postmortem histology (animal and human). Once you've parcellated
the striatum, you can measure properties of those voxels directly, you can use them as seeds or targets for subsequent rounds of tractography, you can 
register them into other imaging volumes for multi-modality studies. 

The included text files (e.g., StriosomeVsMatrix.2018.C.txt) provide the regions that will serve as "bait" for comparitive diffusion tractography. Text
files that include "N-1" in the name are subsidiary versions that leave one region out. These allow you to quantify connectivity for the left-out 
region.

After registering these ROIs into native space for tractography, you should run scripts in this order:

1. DTI_CT_LC.ParcellatesStriatum.GroupOf10...  This generates paired probability distributions of the striatum, one for connectivity with striosome-
favoring bait regions, one for connectivity with matrix-favoring bait regions.

2. DTI_StriosomeVsMatrix_CreatesEqual-sizedStriatalMasks_1.5SD...  This script generates mask files from the striatal probability distributions that have 
equal volume, striosome-like and matrix-like. You need to adjust the target volume to the stringency you desire - our studies have used 1.5SD above the
mean, which is a good compromise between selectivity and having enough voxels to adequatly sample the striatum. For DTI volumes captured at 1.5 mm 
isotropic, this target volume is 180 voxels. For DTI volumes captured at 2 mm isotropic, this target volume is 83 voxels. 

3. DTI_StriosomeVsMatrix_MatchesMatrixToSmallStriosomeMasks_1.5SD... or its "MatchesStriosome" correlate. These scripts create equal volume masks for
subjects/hemispheres that do not solve using the "CreatesEqual" script. Your goal is to have equal volume masks for every subject and hemisphere.

Details of each parcellation group:

2018.C - the final set of regions used for our 2022 NeuroImage methods paper (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9142299/). This set of bait
regions includes both cortical and subcortical ROIs.

2020.C - the set of regions used for our 2023 paper that mapped connectiviy between the striatal compartments and 20 thalamic nuclei. This set of bait 
regions includes ONLY cortical ROIs, as the goal of the paper was to utilize the pallidum and thalamus for mapping and quantifying connectivity.
