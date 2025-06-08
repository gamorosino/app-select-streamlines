#!/bin/bash


nthreads_available () {
            
                        
			local cpu_load=$( echo $( top -b -n2 | grep "Cpu(s)" | awk '{print $2+$4}' | tail -n1 ))		
			local cpu_load_f=$(echo "scale=5; ${cpu_load}/100  " | bc)
			local cpu_num_all_n=$(( $( getconf _NPROCESSORS_ONLN )-0 ))	
			local cores_used=$(echo "scale=5; ${cpu_load_f}*${cpu_num_all_n} " | bc)
			local cores_used=${cores_used%.*}
			local cores_used=$(( ${cores_used}-0 ))								
			local cpu_num_all=$(( cpu_num_all_n-$cores_used))							
			echo $cpu_num_all

			};

# Limit parallel jobs
max_jobs=$( nthreads_available ) 

wait_for_jobs() {
    while [ "$(jobs -r | wc -l)" -ge "$max_jobs" ]; do
        sleep 1
    done
}


tractogram=$1
ecc_polar_dir=$2
ends_only=$3
outputdir=$4

[ "$ends_only" == "true" ] && ends_only_cmd="--ends_only"

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
