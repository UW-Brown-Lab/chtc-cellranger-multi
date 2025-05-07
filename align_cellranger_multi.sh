#!/bin/bash
#
# cellranger_multi.sh
# Alignment of Single Cell RNA Seq
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****CHECK ARGUMENTS*****
#
if [ $# -ne 8 ]; then
    echo 'Please provide all arguments: $(SAMPLE_FILE_PATH) $(SAMPLE_FOLDER_NAME) $(REFERENCE_GENOME_PATH) $(FEATURE_REFERENCE_PATH) $(MULTI_CONFIG_PATH) $(CELLRANGER_PATH) $(JOB_NAME) $(CELLRANGER_DIR_NAME)'
    echo "$@"
    exit 1
fi
SAMPLE_FILE_PATH=${1##*/}
SAMPLE_FOLDER_NAME=$2
REFERENCE_GENOME_PATH=${3##*/}
FEATURE_REFERENCE_PATH=${4##*/}
MULTI_CONFIG_PATH=${5##*/}
CELLRANGER_PATH=${6##*/}
JOB_NAME=$7
CELLRANGER_DIR_NAME=$8
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****UPDATE HOME DIR*****
#
export HOME="$_CONDOR_SCRATCH_DIR"
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****UNPACK CELLRANGER*****
#
echo "UNPACKING CELLRANGER"
tar -xzf "$CELLRANGER_PATH"
echo "Cellranger dir: $CELLRANGER_DIR_NAME"
export PATH="$PWD/$CELLRANGER_DIR_NAME:$PATH"
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****SITECHECK CELLRANGER*****
#
echo "SITECHECK"
cellranger sitecheck > sitecheck.txt
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****UNTAR REF DIR*****
#
echo "UNPACKING REFERENCE"
tar -xzvf "$REFERENCE_GENOME_PATH"
# THIS LINE WILL NEED TO BE CHANGED WHEN REFERENCE CHANGES
tar -xzvf ./cellranger_references/refdata-gex-GRCh38-2024-A.tar.gz
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****UNTAR RAW READ DIR*****
# Change file name as needed
#
echo "UNPACKING RAW READS"
tar -xzvf "$SAMPLE_FILE_PATH"
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****RENAME FASTQ FILES*****
# Change file name as needed
#
echo "RENAMING FASTQs"
chmod +x rename_fastq.sh
./rename_fastq.sh ./"$SAMPLE_FOLDER_NAME"
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****UPDATE MULTI CONFIG*****
#
echo "INSERTING PWD INTO CONFIG"
chmod +x generate_multi.sh
./generate_multi.sh "$MULTI_CONFIG_PATH"
#
# CHECK CSV BEFORE LAUNCH
echo "PRINTING MULTI CONFIG"
cat "$MULTI_CONFIG_PATH"
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****SHOW FILES*****
#
echo "SHOWING ALL FILES"
ls -l
ls -l ./cellranger_references/
ls -l ./refdata-gex-GRCh38-2024-A
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****RUN MULTI*****
#
#
echo "LAUNCHING CELLRANGER"
cellranger multi --id="$JOB_NAME" --csv="$MULTI_CONFIG_PATH" --localmem 72
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# *****ZIP OUTPUT*****
#
echo "ZIPPING OUTPUT"
mv sitecheck.txt ./"$JOB_NAME"/
#
tar -czvf cellranger_output.tar.gz "$JOB_NAME"
#


