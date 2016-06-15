#!/bin/sh

SOURCE_FILE="${SRCROOT}/Pods/Target Support Files/Pods-${EXECUTABLE_NAME}/Pods-${EXECUTABLE_NAME}-acknowledgements.plist"
TARGET_FILE="${TARGET_BUILD_DIR}/${EXECUTABLE_NAME}.app/Settings.bundle/Pods-acknowledgements.plist"

#location of symbolic link creator
CP="/bin/cp"

$CP "${SOURCE_FILE}" "${TARGET_FILE}"

echo "SOURCE_FILE = ${SOURCE_FILE}"
echo "TARGET_FILE = ${TARGET_FILE}"

INFOPLISTPATH="${TARGET_BUILD_DIR}/${EXECUTABLE_NAME}.app/Info.plist"

# Location of PlistBuddy
PLISTBUDDY="/usr/libexec/PlistBuddy"

BUILD_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFOPLISTPATH}")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLISTPATH}")
# Get the current git commmit hash (first 7 characters of the SHA)
GITREVSHA=$(git --git-dir="${PROJECT_DIR}/.git" --work-tree="${PROJECT_DIR}" rev-parse --short HEAD)

echo "INFOPLISTPATH = ${INFOPLISTPATH}"
echo "BUILD_VERSION = ${BUILD_VERSION}"
echo "BUILD_NUMBER = ${BUILD_NUMBER}"
echo "GIT SHA = ${GITREVSHA}"

