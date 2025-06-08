#! /bin/bash


CPUs_available () {
        
                        
			local cpu_load=$( echo $( top -b -n2 | grep "Cpu(s)" | awk '{print $2+$4}' | tail -n1 ))		
			local cpu_load_f=$(echo "scale=5; ${cpu_load}/100  " | bc)
			local cpu_num_all_n=$(( $( getconf _NPROCESSORS_ONLN )-0 ))	
			local cores_used=$(echo "scale=5; ${cpu_load_f}*${cpu_num_all_n} " | bc)
			local cores_used=${cores_used%.*}
			local cores_used=$(( ${cores_used}-0 ))								
			local cpu_num_all=$(( cpu_num_all_n-$cores_used))							
			echo $cpu_num_all

			};

imm_unpackSeg() {
    if [ $# -lt 1 ]; then
        echo "$0: usage: imm_unpackSeg <segmentation.ext> [<output_folder>]"
        return 1
    fi

    local seg=$1
    local ofolder=$2
    local base_name=$(basename "$seg" | sed 's/\..*//')
    [ -z "${ofolder}" ] && {
        ofolder=$(dirname "$seg")'/'"${base_name}_unpackSeg/"
    }

    mkdir -p "$ofolder"

    python3 - <<EOF
import os
import nibabel as nib
import numpy as np

def unpack_segmentation(segmentation_file, output_folder, base_name):
    os.makedirs(output_folder, exist_ok=True)
    img = nib.load(segmentation_file)
    data = np.round(img.get_fdata()).astype(int)
    unique_labels = np.unique(data)
    for label in unique_labels:
        if label == 0:
            continue
        label_data = (data == label).astype(np.uint8)
        label_img = nib.Nifti1Image(label_data, img.affine, img.header)
        label_filename = os.path.join(output_folder, f"{base_name}_{label}.nii.gz")
        nib.save(label_img, label_filename)

unpack_segmentation("$seg", "$ofolder", "$base_name")
EOF
}

# Controls how many jobs run in parallel
max_jobs=$( CPUs_available )

wait_for_jobs() {
    while (( $(jobs -r | wc -l) >= max_jobs )); do
        sleep 1
    done
}

tractogram=$1
parc=$2
ends_only=$3
outputdir=$4

[ "${ends_only}" == "true" ] && ends_only_cmd="--ends_only"

ecc_polar_dir=./ecc_polar
mkdir -p "${ecc_polar_dir}"

imm_unpackSeg "$parc" "$ecc_polar_dir"
mkdir -p "${outputdir}"

count=0

for parcel in "${ecc_polar_dir}"/*; do
    count=$((count + 1))
    tck="track_${count}.tck"

    wait_for_jobs

    tckedit "${tractogram}" -include "${parcel}" ${ends_only_cmd} "${outputdir}/${tck}" &
done

wait  # Wait for all background jobs to finish
