#!/bin/bash

tractogram=$1
ecc_polar_dir=$2
ends_only=$3
outputdir=$4

mkdir -p "$outputdir"

count=0
shopt -s nullglob  # Avoid literal *.nii.gz if no files found
for parcel in "$ecc_polar_dir"/*.nii.gz; do
    count=$((count + 1))
    tck="track_${count}.tck"

    wait_for_jobs

    tckedit "$tractogram" -include "$parcel" ${ends_only_cmd} "$outputdir/$tck" &
done

wait  # Wait for background jobs
