#!/usr/bin/env bash

#Destination folder for training images
DEST_DIR=$1
#What percentage of total files will be used for training and test
#Expected values are from 0-100
PCT_OF_FILES_TO_USE=$2
#Folder with normal source images
NORMAL_IMAGES_DIR=$3
#Folder with defects source images
DEFECTS_IMAGES_DIR=$4
#Where images that are selected are copied to
PROJECT_IMAGES_DIR=images

print_usage() {
  cat <<END
Usage:
  $0 project_name pct_of_files_to_use normal_images_dir defects_images_dir

Where:
  dest_dir: directory where training images will be copied, does not have to exist at the time when script is run.
  pct_of_files_to_use: percentage of images that will be used in training, using smaller subset of total images can increase training and reduced training costs.
  normal_images_dir: folder where normal source images are stored.
  defects_images_dir: folder where defects source images are stored.
END
}

# The function requires three arguments in the following order:
# 1. directory of images that will be copied
# 2. directory where images will be copied
# 3. percentage of source images that will be copied to destination folder, value between 0-100
copy_images() {
  if [ $# != 3 ]; then echo "$FUNCNAME: Improper invocation of copy_images function, exiting."; return 1; fi
  if [ ! -d "$1" ]; then echo "$FUNCNAME: The source directory $1 does not exist, exiting."; return 1; fi
  source_images_total=$(ls "$1"/*.png | wc -l)
  source_images_num=$((source_images_total*$3/100))
  source_images_to_copy=$(ls "$1"/*.png | shuf | head -n $source_images_num)
  echo "$FUNCNAME - Creating destination folder $2 ..."
  mkdir -p "$2" && echo "OK."
  echo "$FUNCNAME - Copying source images to destination folder ..."
  for f in $source_images_to_copy; do
    if (! ( cp "$f" "$2" )); then echo "$FUNCNAME: Failed to copy source image $f, exiting $FUNCNAME ..."; return 1; fi
  done
  echo "OK."
}

main() {
  if [ $# != 4 ]; then print_usage; exit 1; fi
  echo "$FUNCNAME: Creating $1 directory ..."
  mkdir -p "$1" && echo "OK."
  copy_images "$3" "$1/normal" $PCT_OF_FILES_TO_USE
  copy_images "$4" "$1/defects" $PCT_OF_FILES_TO_USE
}

main "$DEST_DIR" "$PCT_OF_FILES_TO_USE" "$NORMAL_IMAGES_DIR" "$DEFECTS_IMAGES_DIR"

