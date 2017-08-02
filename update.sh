#!/bin/bash

function get_file {
  DOWNLOAD_PATH=${2}?raw=true
  SAVE_PATH=${3}
  TMP_NAME=${1}.tmp
  echo "Getting $1"
  wget $DOWNLOAD_PATH -q -O $TMP_NAME
  rv=$?
  if [ $rv != 0 ]; then
    rm $TMP_NAME
    echo "Download failed with error $rv"
    exit
  fi
  diff ${SAVE_PATH}$1 $TMP_NAME &>/dev/null
  if [ $? == 0 ]; then
    echo "File up to date."
    rm $TMP_NAME
    return 0
  else
    mv $TMP_NAME ${SAVE_PATH}$1
    if [ $1 == $0 ]; then
      chmod u+x $0
      echo "Restarting"
      $0
      exit $?
    else
      return 1
    fi
  fi
}

function get_file_and_gz {
  get_file $1 $2 $3
  r1=$?
  get_file ${1}.gz ${2}.gz $3
  r2=$?
  if (( $r1 != 0 || $r2 != 0 )); then
    return 1
  fi
  return 0
}

function check_dir {
  if [ ! -d $1 ]; then
    read -p "$1 dir not found. Create? (y/n): [n] " r
    r=${r:-n}
    if [[ $r == 'y' || $r == 'Y' ]]; then
      mkdir -p $1
    else
      exit
    fi
  fi
}

get_file $0 https://github.com/andrey-git/home-assistant-custom-ui/blob/master/update.sh .


check_dir "www/custom_ui"

get_file_and_gz state-card-custom-ui.html https://github.com/andrey-git/home-assistant-custom-ui/blob/master/state-card-custom-ui.html www/custom_ui/

if [ $? != 0 ]; then
  echo "Updated to Custom UI `grep -o -e "'[0-9][0-9][0-9]*'" www/custom_ui/state-card-custom-ui.html`"
fi



check_dir "panels"

get_file_and_gz ha-panel-custom-ui.html https://github.com/andrey-git/home-assistant-custom-ui/blob/master/ha-panel-custom-ui.html panels/

if [ $? != 0 ]; then
  echo "Updated Panel to `grep -o -e "'[0-9][0-9][0-9]*'" panels/ha-panel-custom-ui.html`"
fi


check_dir "custom_components/customizer"

get_file __init__.py https://github.com/andrey-git/home-assistant-customizer/blob/master/customizer/__init__.py custom_components/customizer/
get_file services.yaml https://github.com/andrey-git/home-assistant-customizer/blob/master/customizer/services.yaml custom_components/customizer/
