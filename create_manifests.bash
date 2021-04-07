#!/usr/bin/env bash

print_usage () {
  cat <<END
Usage:
    $0 files_dir bucket_name label class output_file_prefix

Where:
    files_dir: files directory where files are located.
    bucket_name: a bucket name where the files will be stored.
    label: label of a sample, numeric value
    class: a name of the class to which a sample belongs
    output_file_prefix: prefix of the output files containing the training and test images metadata.
END
}

output_to_manifest() {
  bucket_name="$1"
  class="$2"
  label="$3"
  manifest_file="$4"
  shift 4
  images=($@)
  for img_path in "${images[@]}"; do
    img_name="${img_path##*/}"
    text="{\"source-ref\":\"s3://$bucket_name/$label/$img_name\",\"anomaly-label\":$label,\"anomaly-label-metadata\":{\"confidence\":1,\"class-name\":\"$class\",\"human-annotated\":\"yes\",\"creation-date\":\"2021-04-06T19:18:44.208156\",\"type\":\"groundtruth/image-classification\"}}"
    echo "$text" >> "$manifest_file"
  done
}

FILES_DIR="$1"
BUCKET_NAME="$2"
LABEL="$3"
CLASS="$4"
OUTPUT_FILE="$5"
TEST_FILE="$OUTPUT_FILE"_test.txt
TRAIN_FILE="$OUTPUT_FILE"_train.txt

if [ $# != 5 ]; then print_usage; exit 1; fi
if [ ! -d "$FILES_DIR" ]; then echo "$FUNCNAME: Folder $FILES_DIR does not exist."; fi

files=($(ls "$FILES_DIR"/*))
files_count=${#files[@]}
# 80% of total images will be used for training and the rest 20% will be used for testing.
train_files_count=$((files_count*80/100))
# select training images
train_files=${files[@]:0:$train_files_count}
# select test images
test_files=${files[@]:$train_files_count}

# Output information about training images to the training manifest file.
output_to_manifest "$BUCKET_NAME" "$CLASS" "$LABEL" "$TRAIN_FILE" "${train_files[@]}"
# Output information about test images to the test manifest file.
output_to_manifest "$BUCKET_NAME" "$CLASS" "$LABEL" "$TEST_FILE" "${test_files[@]}"
