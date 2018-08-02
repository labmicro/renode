#!/bin/bash

set -e
set -u

#change dir to script location
cd "${0%/*}"
. common_make_packages.sh

if ! is_dep_available zip
then
    exit
fi

DIR=renode_$VERSION

SED_COMMAND="sed -i"
. common_copy_files.sh

PACKAGES=output/renode_packages/$TARGET
OUTPUT=$BASE/$PACKAGES

### copy windows dependencies
cp "`which libgcc_s_seh-1.dll`" $DIR/bin
cp windows/mingw-license $DIR/licenses

MSBuild.exe /t:Clean,Build windows/RenodeSetup/SetupProject.wixproj /p:version=${VERSION%\+*} /p:workdir=$DIR

### create windows package
if $REMOVE_WORKDIR
then
    zip -qrm $DIR.zip $DIR/
else
    zip -qr $DIR.zip $DIR/
fi

mkdir -p $OUTPUT/windows
mv $DIR.zip $OUTPUT/windows
mv windows/RenodeSetup/bin/Release/RenodeSetup.msi $OUTPUT/windows

echo "Created a Windows package in $PACKAGES/windows/$DIR.zip"
echo "Created a Windows installer in $PACKAGES/windows/RenodeSetup.msi "
