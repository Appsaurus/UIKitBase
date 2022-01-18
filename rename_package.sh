#!/bin/bash

OLD_PROJECT_NAME="UIKitBase"
NEW_PROJECT_NAME=""

case $# in
  0)
    echo "Please supply a package name."
    exit
    ;;
  1)
    NEW_PROJECT_NAME=$1
    ;;

  2)
    OLD_PROJECT_NAME=$1
    NEW_PROJECT_NAME=$2
    ;;

  *)
    echo "Too many arguments."
    exit
esac

curl https://raw.githubusercontent.com/acefsm/rename_xcode_project/main/rename_xcode_project.sh -o rename_xcode_project.sh && chmod +x rename_xcode_project.sh

./rename_xcode_project.sh $OLD_PROJECT_NAME $NEW_PROJECT_NAME

rm rename_xcode_project.sh
