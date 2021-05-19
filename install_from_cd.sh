#!/bin/sh

mk_pk3()
{
	tree -fi > ./build_contents.txt
	sed -i '/build_contents/d' ./build_contents.txt
	sed -i '/directories,/d' ./build_contents.txt
	zip -0 "$1".pk3 -@ < ./build_contents.txt
	rm ./build_contents.txt
	mv "$1".pk3 ../"$1".pk3
}

# grabs a patch .zip from archive.org and saves it as a pk3
grab_patch()
{
	wget -nc -O ./pak$2.pk3 http://archive.org/download/hl_shareware_data/gearbox/$1.zip
}

SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
OUTPK3DIR="pak1_retail.pk3dir"

if ! [ -x "$(command -v rsync)" ]; then
	printf "Error: rsync is not installed.\n" >&2
	exit 1
fi
if ! [ -x "$(command -v tree)" ]; then
	printf "Error: tree is not installed.\n" >&2
	exit 1
fi
if ! [ -x "$(command -v zip)" ]; then
	printf "Error: zip is not installed.\n" >&2
	exit 1
fi

if ! [ $# -gt 0 ]; then
	printf "Path to MOUNTED CD-ROM folder, e.g. /mnt/cdrom:\n"
	read CDROM_PATH
else
	CDROM_PATH="$1"
fi

if ! [ -f "$CDROM_PATH"/OPFOR/gearbox/pak0.pak ]; then
	printf "Error: pak0.pak not found in $CDROM_PATH.\n" >&2
	exit 1
fi

# Let's shove them all into a convenient .pk3dir
mkdir -p "./$OUTPK3DIR"
rsync -av "$CDROM_PATH"/OPFOR/gearbox/ "./$OUTPK3DIR/"
chmod -R +w "./$OUTPK3DIR/"
mv -v "./$OUTPK3DIR/pak0.pak" ./pak00_cd.pak
cd "./$OUTPK3DIR"
mk_pk3 pak01_cd
cd "$SCRPATH"

# Get the latest patch, because that'll fix the menu assets and add more fun, free content
grab_patch 10011100 02_1100
grab_patch 11001101 03_1101
grab_patch 11011103 04_1103
grab_patch 11031104 05_1104
grab_patch 11041106 06_1106
grab_patch 11061108 07_1108
grab_patch 11081109 08_1109

rm -rfv "./$OUTPK3DIR"
