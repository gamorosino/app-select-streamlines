<h1 align="center">Streamline Selection by Parcellation</h1>

<p align="center">
  An automated and reproducible pipeline to extract streamlines from a tractogram based on a labeled parcellation image.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.866"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.866-blue.svg" alt="Run on brainlife.io"></a>
</p>

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **An automated and reproducible pipeline to extract streamlines from a tractogram based on a labeled parcellation image.**

Splits the parcellation into one binary mask per label (nibabel) and runs MRtrix3 tckedit -include for each mask in parallel, writing one tractogram per parcel; with ends_only only streamlines that terminate in the parcel are kept. Use it to get region-wise bundles from a whole-brain tractogram. The tractogram and parcellation must be in the same space.

| | |
|---|---|
| **Inputs** | `neuro/track/tck` · `neuro/parcellation/volume` |
| **Outputs** | `neuro/tcks` |
| **Container** | `brainlife/dipy:1.4.1` |
| **Resources** | 1 CPUs · 8 GB memory · 2 h walltime |
| **Run it** | [doi.org/10.25663/brainlife.app.866](https://doi.org/10.25663/brainlife.app.866) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `tractogram` | `neuro/track/tck` | yes | Whole-brain .tck tractogram. Same space as the parcellation. |
| `parcellation` | `neuro/parcellation/volume` | yes | Labeled volumetric parcellation; each non-zero label becomes one ROI. |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `tcks` | `neuro/tcks` | One .tck tractogram per parcellation label with the streamlines that intersect (or end in) that parcel. |

<details>
<summary><b>Parameters</b> (1)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `ends_only` | boolean | `false` | filtering only the streamlines ending in the parcels |

</details>

<!-- brainlife-app:end -->

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.866](https://doi.org/10.25663/brainlife.app.866), choose `neuro/track/tck`, `neuro/parcellation/volume` from your project, set the parameters and press **Execute**. The results are saved to your project as `neuro/tcks`.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/) (the App runs in `brainlife/dipy:1.4.1`), [`jq`](https://jqlang.github.io/jq/).

1. Clone this repository.
2. Create `config.json` with the paths to your inputs and the parameters:

   ```json
   {
       "tractogram": "/path/to/tractogram/tractogram",
       "parc": "/path/to/parcellation/parc",
       "key": "/path/to/parcellation/key",
       "label": "/path/to/parcellation/label",
       "ends_only": false
   }
   ```

3. Run `./main`.

## Via Web UI

- Go to Brainlife.io and search for the `app-segmentation2tracts` app.  
- Click the **Execute** tab.  
- Upload the following inputs:
  - Whole-brain tractogram (.tck)
  - Labeled parcellation file (.nii.gz)
  - (Optional) `ends_only` flag to restrict by streamline endpoints  
- Submit the job to generate per-region streamline bundles.

## Via CLI

Install the Brainlife CLI: https://brainlife.io/docs/cli/  
Log in:
```bash
bl login
```
Run the app:
```bash
bl app run --id <app_id> --project <project_id> \
  --input tractogram:<tractogram_id> \
  --input parc:<parcellation_id> \
  --input ends_only:true
```
Replace dataset and project IDs as appropriate.

## Using a Configuration File

Clone the repository:
```bash
git clone https://github.com/gamorosino/app-segmentation2tracts.git
cd app-segmentation2tracts
```

Prepare a config.json file:
```json
{
    "tractogram": "sub-01_dwi_tracts.tck",
    "parcellation": "sub-01_parc.nii.gz",
    "ends_only": "true",
    "output_dir": "./tracts_by_region"
}
```

Run the pipeline:
```bash
bash ./main sub-01_dwi_tracts.tck sub-01_parc.nii.gz true ./tracts_by_region
```

Outputs  
- `ROIs/` — Unpacked binary masks from the segmentation  
- `tracts_by_region/` — Streamlines intersecting each parcel (`track_<label>.tck`)

## Citing

If you use this App, please cite it, the software it builds on and brainlife.io:

- Streamline Selection by Parcellation. brainlife.io App. [doi:10.25663/brainlife.app.866](https://doi.org/10.25663/brainlife.app.866)
- Tournier JD, Smith R, Raffelt D, et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. NeuroImage 202, 116137 (2019). [doi:10.1016/j.neuroimage.2019.116137](https://doi.org/10.1016/j.neuroimage.2019.116137)
- Tournier, J. D., Smith, R., Raffelt, D., et al. (2019). MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage*, 202, 116137.
- Hayashi, S., Caron, B. A., Heinsfeld, A. S., ... & Pestilli, F. (2024). brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods*, 21(5), 809–813.
- Garyfallidis et al. Dipy, a library for the analysis of diffusion MRI data. *Frontiers in Neuroinformatics* 8 (2014). [doi:10.3389/fninf.2014.00008](https://doi.org/10.3389/fninf.2014.00008)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

Gabriele Amorosino  
(email:
