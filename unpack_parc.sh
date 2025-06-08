#! /bin/bash

# Function to unpack segmentation
imm_unpackSeg() {
    if [ $# -lt 1 ]; then
        echo "$0: usage: imm_unpackSeg <segmentation.ext> [<output_folder>]"
        return 1
    fi

    local seg=$1
    local ofolder=$2
    local base_name=$(basename "$seg" | sed 's/\..*//')

    if [ -z "$ofolder" ]; then
        ofolder=$(dirname "$seg")/"${base_name}_unpackSeg/"
    fi

    mkdir -p "$ofolder"

    python <<EOF
import os
import nibabel as nib
import numpy as np

segmentation_file = "${seg}"
output_folder = "${ofolder}"
base_name = "${base_name}"

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

img = nib.load(segmentation_file)
data = np.round(img.get_fdata()).astype(int)
labels = np.unique(data)

for label in labels:
    if label == 0:
        continue
    label_data = (data == label).astype(np.uint8)
    label_img = nib.Nifti1Image(label_data, img.affine, img.header)
    label_filename = os.path.join(output_folder, "{}_{}.nii.gz".format(base_name, label))
    nib.save(label_img, label_filename)
EOF
}


# Parse arguments
parc=$1
ecc_polar_dir=$2

mkdir -p "${ecc_polar_dir}"

imm_unpackSeg "$parc" "$ecc_polar_dir"
