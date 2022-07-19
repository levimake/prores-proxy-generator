#!/usr/bin/env bash

# Usage notes
# ===========
#
# proxy_watermark.png needs to be in the same directory as the script
#
# on OSX, both pv and ffmpeg will need to be installed via homebrew

if [ -z "$1" ]
  then
    echo "Input location not specified"
    exit
fi

#INPUT LOCATION
scriptdir="$1"


#CREATING A FOLDER TO STORE THE PROXIES
mkdir -p $1/Proxies

#MOVING THE WATERMARK.PNG TO INPUT FOLDER
cp proxy_watermark.png $scriptdir

cd $scriptdir

#OUTPUT RESOLUTION [defaults to 720p in case of wrong input]
x=1280
y=720

if [ "$2" = "720p" ]
  then
    x=1280
    y=720
else
  if [ "$2" = "1080p" ]
    then
      x=1920
      y=1080
  else
    if [ "$2" = "4K" ]
      then
        x=3840
        y=2160
    fi
  fi
fi
outputres="$x:$y"

echo "outputres = $outputres"

# input aspects:
#   cine 4K = 4096:2160 (1.9:1 = 1.896) - proxy at 1024:540
#   UHD(4K) = 3840:2160 (16:9 = 1.777) - proxy at 720p
#   1080p = 1920:1080 (16:9 = 1.777) - proxy at 720p
#   720p = 1280:720 (16:9 = 1.777)
#
# proxy aspects:
#    1024x540 = 1.9:1
#    1280x720 = 16:9
#    1536x790 = ???  (1.944)


#BATCH_RUN THROUGH ALL MOVS IN THERE
for inputfile in *.MOV; do

#re-initialize output resolution
outputres="$x:$y"

nakedname="${inputfile%.*}"
ext="${inputfile##*.}"
#outputfile="$1/Proxies/${nakedname}-proxy.${ext}" 
outputfile="$1/Proxies/${nakedname}.${ext}"

echo "inputfile = $inputfile"
echo "outputfile = $outputfile"

# find input resolution
# =====================
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $inputfile)
inputres=${streams_stream_0_width}:${streams_stream_0_height}

#ADJUSTMENTS FOR C4K, 4:3 and 3:2 inputs

if [ "$inputres" = "4096:2160" ] #C4K
  then
    if [ $y -eq 720 ] 
      then 
        outputres="1024:540" 
    fi 
    if [ $y -eq 1080 ] 
      then 
        outputres="1920:1010" 
    fi
    if [ $y -eq 2160 ] 
      then 
        outputres="4096:2160" 
    fi
else
    #4:3
    if [ "$inputres" = "3328:2496" ]
	    then
        if [ $y -eq 720 ] 
          then 
            outputres="960:720" 
        fi
        if [ $y -eq 1080 ] 
          then 
            outputres="1440:1080" 
        fi
        if [ $y -eq 2160 ] 
          then 
            outputres="2880:2160" 
        fi
    else
      #14:9
      if [ "$inputres" = "5952:3968" ]
        then
          if [ $y -eq 720 ] 
            then 
              outputres="1120:720" 
          fi 
          if [ $y -eq 1080 ] 
            then 
              outputres="1680:1080" 
          fi
          if [ $y -eq 2160 ] 
            then 
              outputres="3360:2160" 
          fi
      fi
    fi
fi 

echo "scriptdir = $scriptdir"	
echo "inputres = $inputres"
echo "outputres = $outputres"

# EXPLANATION
# ===========
#
#   pv = pipeview, shows progress and estimated time
#
#   -v warning  turn down verbosity to only warnings
#
#   -profile:v N
#     where N = 0 -> proxy  1 -> lt  2 -> std  3 -> hq
#
#   -i logo.png = a SECOND input file, with an overlay image
#   -filter_complex "overlay=W-w-5:H-h-5/2" = make an overlay, position 5px from bottom-right
#

pv $inputfile | ffmpeg \
  -loglevel warning \
  -i pipe:0 \
  -i $scriptdir/proxy_watermark.png \
  -filter_complex "[0:v]scale=$outputres, overlay=W-w-5:H-h-5/2" \
  -codec:a copy \
  -pix_fmt yuv422p10le \
  -codec:v prores \
  -profile:v 0 \
  $outputfile

done

rm proxy_watermark.png