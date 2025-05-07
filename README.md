# chtc-cellranger-multi
Template scripts for running Cell Ranger Multi on UW CHTC

## Description
This repository is home to a couple simple scripts that facilitate running Cell Ranger multi on the UW CHTC by adding adjustable parameters to the top of the submission file. This greatly reduces the amount of manual configuration needed from run to run, although some is still necessary

## Parameters
Below is a description of each parameter that gets passed into the shell script.

### SUBMISSION_NAME
This will likely need to be changed from run to run. It's not technically a requirement, but this name will be appended to the logs, the output, and passed into cellranger itself.

### SAMPLE_FOLDER_NAME
This is the name of the directory that contains the fastq files. This is not necessarily the same as the name of the .tar.gz file (although it may be wise to follow that convention for your own sake). This is the name of the folder _inside_ of the .tar.gz that will be present after unzipping it.

### SAMPLE_FILE_PATH
This is the path to the aforementioned tar.gz file that will get transferred into CHTC. This must either be relative to the submission node or, more likely, an absolute path to the staging node. For example:
`file:///staging/groups/your_group_name/your_file.tar.gz`

### TOTAL_DISK_SPACE
This is how much disk space your are requesting from CHTC. Keep in mind that Cell Ranger needs more headroom than simply enough space to store the fastq files!

### REFERENCE_GENOME_PATH
This is the absolute path to the tar.gz file containing the references. This must either be relative to the submission node or, more likely, an absolute path to the staging node. For example:
`file:///staging/groups/your_group_name/cellranger_references.tar.gz`
<details>
<summary>CAUTION</summary>
<br>
If you need to update / repackage the references, the executable shell script will also need to be updated! Whether a consequence of laziness or simply because it does not seeem to be worth the time at present, the shell script is hardcoded around unpacking this particular reference file -- specifically concerning `refdata-gex-GRCh38-20240A.tar.gz` inside of the references tarball. If you change/update the references, this section of the `align_cellranger_multi.sh` file under `*****UNTAR REF DIR*****` will need to be updated.
</details>

### FEATURE_REFERENCE_PATH
This is the path to the feature_reference.csv file. **This argument must be provided and this file must exist regardless of whether it is needed in the multi_config.csv or not!** This must either be relative to the submission node or an absolute path to the staging node. For example:
`file:///staging/groups/your_group_name/feature_reference.csv`

<details>
<summary>More about Feature Reference</summary>
<br>
Generally, a feauture reference is needed for multimodal assays, such as antibody capture (Cell hashing).
For more about how to format/structure the feature_reference.csv, visit 10X Genomics documentation available here:
[Link](https://www.10xgenomics.com/support/software/cell-ranger/latest/analysis/inputs/cr-feature-ref-csv)
</details>

### MULTI_CONFIG_CSV_PATH
This is the path to the multi_config.csv configured for this specific run. This specific file will need to be modified for every run. The path must either be relative to the submission node or an absolute path to the staging node. For example: 
`multi_config.csv`
<details>
<summary>More about Multi Config</summary>
<br>
The multi config is what must be adjusted every run to specify details about the sample and its fastq files. Cell Ranger requires absolute file paths, which we are unable to predict when using CHTC. Because of this, the utility scripts support using `$PWD` notation for the present working directory in the multi_config.csv file paths. Additional information about how to structure the rest of the config and the available options can be found in the 10X Genomics documentation available here:
[Link](https://www.10xgenomics.com/support/software/cell-ranger/latest/advanced/cr-multi-config-csv-opts)
</details>

### CELLRANGER_PATH
This is the path to the tar.gz file containing Cell Ranger multi. The path must either be relative to the submission node or an absolute path to the staging node. For example: 
`cellranger-8.0.0.tar.gz`
<details>
<summary>On Updating Cell Ranger</summary>
<br>
In order to update Cell Ranger, a new tarball must be created with the given version. There are numerous ways of doing this -- one easy one is to launch an interactive session on CHTC and install cellranger into a folder by following the steps on 10X's website. Updating Cell Ranger may or may not require additional modifications to these scripts beyond these parameters.
</details>

### CELLRANGER_DIR_NAME
This is the name of the directory inside of the unpackaged tarball containing Cell Ranger. For example, at the time of creation of this repository, we're using Cell Ranger 8, which is in a folder aptly named `cellranger-8.0.0`

### UTILS
Is parameter contains comma separated paths to two specific utility scripts designed to facilitate this process even more: `generate_multi.sh` and `rename_fastq.sh` These files can be located anywhere accessible to CHTC, but their names must be the same and they are required for the alignment to succeed.
Example input: `generate_multi.sh, rename_fastq.sh`

#### generate_multi.sh
The main role of this script is to replace all instances of `$PWD` in the `multi_config.csv` file with the absolute path to the present working directory. This allows us to assign sample paths with a relative frame of reference even though Cell Ranger requires absolute paths.

#### rename_fastq.sh
I don't truthfully remember the *exact* problem this solves. This script replaces the illumina naming convention's sample number with `S1`. Cell Ranger is very strict on naming conventions, and I believe it expects all sample numbers from 1 to the number of samples present; I think it is intolerant of simply just processing sample 17, for example. This script solves this problem by iterating through the fastq files, finding the sample number with regex, and replacing it with `S1`.

