#! /bin/bash

imm_unpackSeg() {
    if [ $# -lt 1 ]; then  # Check if at least one argument is provided
        echo "$0: usage: imm_unpackSeg <segmentation.ext> [<output_folder>]"
        return 1
    fi  

    local seg=$1
    local ofolder=$2

    # Extract filename without extension
    local base_name=$(basename "$seg" | sed 's/\..*//')

    # If output folder is not provided, set default to <filename>_unpackSeg
    [ -z "${ofolder}" ] && { 
        ofolder=$(dirname "$seg")'/'"${base_name}_unpackSeg/"
    }

    mkdir -p "$ofolder"

    # Call the Python function
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


tractogram=$1
parc=$2
ends_only=$3

[ "${ends_only}"  == "true" ] && { ends_only=" --nds_only "; }

ecc_polar_dir=./ecc_polar
mkdir ${ecc_polar}

imm_unpackSeg $parc ${ecc_polar_dir}
mkdir ./tcks
count=0

for parcel in $( ls ${ecc_polar_dir}/* ); do

  count=$(( $count + 1 ))
  tck=track_${count}.tck
  tckedit ${tractogram} -include ${parcel} ${ends_only_cmd} ./tcks/${tck}
  
fi
