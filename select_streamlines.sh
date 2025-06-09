#!/bin/bash



wait_for_jobs() {
	local max_jobs=$1
    while [ "$(jobs -r | wc -l)" -ge "$max_jobs" ]; do
        sleep 1
    done
}


tractogram=$1
ecc_polar_dir=$2
ends_only=$3
outputdir=$4
max_jobs=$5

[ "$ends_only" == "true" ] && ends_only_cmd="--ends_only"

mkdir -p "${outputdir}"

count=0
shopt -s nullglob  # Avoid literal *.nii.gz if no files found
for parcel in "$ecc_polar_dir"/*.nii.gz; do
    count=$((count + 1))
    tck="track_${count}.tck"

    wait_for_jobs ${max_jobs}

    tckedit "$tractogram" -include "$parcel" ${ends_only_cmd} "${outputdir}/${tck}" &
done

wait  # Wait for background jobs
