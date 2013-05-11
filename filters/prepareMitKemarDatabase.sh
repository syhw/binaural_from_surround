#!/bin/bash

cat <<EOF
This data is Copyright 1994 by the MIT Media Laboratory. It is provided free
with no restrictions on use, provided the authors are cited when the data 
is used in any research or commercial application.
EOF

mkdir -p MIT_KEMAR
(
cd MIT_KEMAR
wget -c 'http://sound.media.mit.edu/resources/KEMAR/full.tar.Z'
wget -c 'http://sound.media.mit.edu/resources/KEMAR/compact.tar.Z'
wget -c 'http://sound.media.mit.edu/resources/KEMAR/diffuse.zip'
wget -c 'http://sound.media.mit.edu/resources/KEMAR/KEMAR-FAQ.txt'
wget -c 'http://sound.media.mit.edu/resources/KEMAR/hrtfdoc.ps'
wget -c 'http://sound.media.mit.edu/resources/KEMAR/hrtfdoc.txt'
wget -c 'http://sound.media.mit.edu/resources/KEMAR/README'

mkdir -p diffuse
(
cd diffuse
unzip ../diffuse.zip
)

echo > ../mitKemarDiffuseL.hrtfs
find diffuse | grep 'H.*wav' | while read a
do
	azimuth=`basename $a | sed 's/.*H-*[0-9]*e0*\([0-9]*[0-9]\)a.*/\1/'`
	elevation=`basename $a | sed 's/.*H\(-*[0-9]*\)e[0-9]*a.*/\1/'`
	reversed=$((360-azimuth))
	nearFileL=`dirname $a`/L$elevation''e`printf "%03i" $azimuth`a.wav
	farFileL=`dirname $a`/L$elevation''e`printf "%03i" $reversed`a.wav
	echo $fullFile elevation $elevation azimuth $azimuth reversed $reversed
	sox -c2 $a -c1 $nearFileL remix 1
	echo $elevation $reversed MIT_KEMAR/$nearFileL >> ../mitKemarDiffuseL.hrtfs
	if [ "$azimuth" -eq "0" -o "$azimuth" -eq "180" ]; then continue; fi # angles which are their symetric
	sox -c2 $a -c1 $farFileL remix 2
	echo $elevation $azimuth  MIT_KEMAR/$farFileL >> ../mitKemarDiffuseL.hrtfs
done

echo > ../mitKemarFullL.hrtfs
echo > ../mitKemarFullR.hrtfs
tar xvfz full.tar.Z
for dir in full/elev*
do 
	for a in $dir/*.dat
	do 
		azimuth=`basename $a | sed 's/.*[LHR]-*[0-9]*e0*\([0-9]*[0-9]\)a.*/\1/'`
		elevation=`basename $a | sed 's/.*[LHR]\(-*[0-9]*\)e[0-9]*a.*/\1/'`
		wave=$dir/`basename $a .dat`.wav
		echo $wave
		sox -t raw -r44100 -b 16 -e signed-integer -x $a $wave
		if (echo $wave | grep L)
		then
			echo $elevation $((360-azimuth)) MIT_KEMAR/$wave >> ../mitKemarFullL.hrtfs
		else
			echo $elevation $azimuth  MIT_KEMAR/$wave >> ../mitKemarFullR.hrtfs
		fi
	done
done

)

