#!/bin/bash

# This script performs one-sample t-tests, unpaired t-test of
# seed based connectivity maps. this code also outputs mean connectivity
# (pearson's correlation) maps for each group.
# Use this script after 01_seed_subjects_correlation_maps.sh
# groupA and groupB are the group names contained in the filenames.
# seedlist.txt has been already produced with 01_seed_subjects_correlation_maps.sh
#
# NB: When running the script, make sure the seed names in the $path_seeds folder do not contain underscores.
# We have added an extra check that prints an error and kills the script if an underscore in present.
# To double check the script is appropriately grouping your subjects, the subjects in each group are listed
# in ts_list_${group}_${seed}.txt files in the 04_groups_log folder.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab,
# Istituto Italiano di Tecnologia, Rovereto
# (2018)
# -----------------------------------------------------------

seedlist=seedlist.txt

groupA=KO #edit this
groupB=WT #edit this

path_ts=03_subject_maps #edit this, where your seed based connectivity maps are stored


function check_seed_name {
  seed=$1
  seed_name=$(basename $seed .nii.gz)
  SUB='_' #offending character

  if [[ "$seed_name" == *"$SUB"* ]]; then
    echo "{$seed_name}: This naming convention is not permitted. Please use a seed name without underscores (_)"
    echo "Error: Aborting script"
    exit 1
  fi
}


function seed_group_level_map {

    seed=$1
    seed_name=$(basename $seed .nii.gz)


    3dttest++ \
        -setA 03_subject_maps/*_${groupA}_*_${seed_name}_z.nii.gz \
        -setB 03_subject_maps/*_${groupB}_*_${seed_name}_z.nii.gz \
        -prefix 04_group_level/${seed_name}_results.nii.gz #-paired

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[0]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_group_mean_diff.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[1]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_group_Tstat.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[2]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupA}_mean.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[3]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupA}_Tstat.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[4]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupB}_mean.nii.gz

    3dcalc \
        -a 04_group_level/${seed_name}_results.nii.gz"[5]" \
        -expr "a" \
        -prefix 04_group_level/${seed_name}_${groupB}_Tstat.nii.gz

    rm 04_group_level/${seed_name}_results.nii.gz

}
export -f seed_group_level_map



function check_groups {

   seed=$1
   seed_name=$(basename $seed .nii.gz)

   echo $path_ts/*_${groupA}_*_${seed_name}_z.nii.gz | tr " " "\n" > 04_group_level/logs/tslist_${groupA}_${seed_name}.txt
   echo $path_ts/*_${groupB}_*_${seed_name}_z.nii.gz | tr " " "\n" > 04_group_level/logs/tslist_${groupB}_${seed_name}.txt

}

# Main starts here

mkdir 04_group_level 04_group_level/logs

while read -r seed;
	do
	check_groups $seed
	done < $seedlist

while read -r seed;
	do
	check_seed_name $seed
	done < $seedlist

while read -r seed;
	do
	seed_group_level_map $seed
	done < $seedlist
