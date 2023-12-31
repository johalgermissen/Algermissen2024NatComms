#!/bin/bash

# Concatenate blocks and register to example_func of first block.
#
# Make executable:
# chmod a+x concat_flirt_blocks.sh # 
#
# Submit as job to cluster:
# qsub -N "concat_flirt_blocks" -l walltime=1:00:00,mem=17gb concat_flirt_blocks.sh
# 17 GB works, 15 min. per subject
#
# EEG/fMRI STUDY, DONDERS INSTITUTE, NIJMEGEN.
# J. Algermissen, 2018-2023.

rootDir=/project/3017042.02 # root directory--needs to be adapted to users' own directory structure
fslDir=/opt/fsl/6.0.0/bin # FSL's directory--needs to be adapted to users' own directory structure

# set subject ID, loop
for (( subject=1 ; subject<=36 ; subject++ )); do

	subjectID=`zeropad $subject 3` # subject ID with 3 digits
	echo "Start subject ${subjectID}"

	subDir=${rootDir}/Log/fMRI/sub-${subjectID}

	# Copy block 1:
	blockID=1
	echo "copy block ${blockID}"
	cp ${blockDir}/AROMA/denoised_func_data_nonaggr.nii.gz ${subDir}/postAROMA.nii.gz
	echo "remove obsolete files block ${blockID}"

	blockDir=${subDir}/FEAT_Block${blockID}.feat

	# Realign blocks & attached blocks 2-6:	
	for (( blockID=2 ; blockID<=6 ; blockID++ )); do

		echo "Realign block ${blockID}"
		$fslDir/mcflirt -in ${blockDir}/AROMA/denoised_func_data_nonaggr.nii.gz -reffile ${subDir}/FEAT_Block1.feat/example_func.nii.gz -out ${blockDir}/AROMA/postAROMA_mcflirt.nii.gz # realign to example_func of block1

		echo "Add block ${blockID}"
		$fslDir/fslmerge -t ${subDir}/postAROMA.nii.gz ${subDir}/postAROMA.nii.gz ${blockDir}/AROMA/postAROMA_mcflirt.nii.gz # output, input1, input2

		echo "Remove obsolete files block ${blockID}"
	 	rm ${blockDir}/AROMA/postAROMA_mcflirt.nii.gz 

	done # end of block loop

	echo "Finished subject ${subjectID}"

done # end of subject loop
