#!/bin/bash

# Use current directory as input
INPUT_DIR="$(pwd)"

# Loop over all mp4 files in the current directory
for filepath in "$INPUT_DIR"/*.mp4; do
    # Skip if no files match
    [ -e "$filepath" ] || continue

    # Extract filename without extension
    filename=$(basename "$filepath")
    name="${filename%.*}"
    ext="${filename##*.}"
    
    echo "Processing '$filename'"
    
    # Converts any video into a vertical 1080×1920 format with blurred background while keeping the original video in the center.
    output="$INPUT_DIR/${name}-scale-V.${ext}"
    # SLOOOOW	
    ffmpeg -i "$filepath"  -filter_complex "[0:v]scale=1080x1920,boxblur=40,setsar=1[bg];[0:v]scale=1080:1920:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=y=(H-h)/2" -c:a copy "$output"
    # ALTERNATIVE
    # CUDA accelerated blur + scale
    # NOT WORKING EVENTHOUGH I BUILT IT
    # ~/GitHub/FFmpeg/ffmpeg -hwaccel cuda -i "$filepath" \
    # -filter_complex "[0:v]scale_cuda=1080:1920:force_original_aspect_ratio=decrease[fg]; \
    # [0:v]scale_cuda=1080:1920[scaled]; \
    # [scaled]boxblur_cuda=40[bg]; \
    # [bg][fg]overlay_cuda=y=(H-h)/2" \
    # -c:v h264_nvenc -preset fast -c:a copy "$output"
    
    
    # Fast Gaussian blur (NOT SO FAST!)
    # ffmpeg -i "$filepath" -filter_complex "[0:v]gblur=sigma=25,scale=1080:1920,setsar=1[bg];[0:v]scale=1080:1920:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=y=(H-h)/2" -c:a copy "$output"


    
    
    # Convert a 1080p horizontal video (1920×1080) into a vertical 1080×1920 by cropping the sides (not stretching)
    output="$INPUT_DIR/${name}-cut-V-1080.${ext}"
    ffmpeg -i "$filepath" -vf "crop=1080:1920:(in_w-1080)/2:(in_h-1920)/2" -preset veryfast "$output"
    
    
done

