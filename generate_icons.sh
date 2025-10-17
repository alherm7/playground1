#!/bin/bash

# Script to generate iOS app icons from SVG
# Requires: ImageMagick (brew install imagemagick)

echo "Generating iOS app icons..."

# Create output directory
mkdir -p ios_icons

# Function to generate icon
generate_icon() {
    local size=$1
    local filename=$2
    local input_svg=$3
    
    echo "Generating ${filename} (${size}x${size})"
    
    # Use ImageMagick to convert SVG to PNG
    magick -background transparent -size ${size}x${size} "${input_svg}" "ios_icons/${filename}"
}

# Generate all required iOS icon sizes
# iPhone icons
generate_icon 40 "Icon-App-20x20@2x.png" "logo_simple.svg"
generate_icon 60 "Icon-App-20x20@3x.png" "logo_simple.svg"
generate_icon 29 "Icon-App-29x29@1x.png" "logo_simple.svg"
generate_icon 58 "Icon-App-29x29@2x.png" "logo_simple.svg"
generate_icon 87 "Icon-App-29x29@3x.png" "logo_simple.svg"
generate_icon 80 "Icon-App-40x40@2x.png" "logo_simple.svg"
generate_icon 120 "Icon-App-40x40@3x.png" "logo_simple.svg"
generate_icon 120 "Icon-App-60x60@2x.png" "logo_simple.svg"
generate_icon 180 "Icon-App-60x60@3x.png" "logo_simple.svg"

# iPad icons
generate_icon 20 "Icon-App-20x20@1x.png" "logo_simple.svg"
generate_icon 40 "Icon-App-20x20@2x.png" "logo_simple.svg"
generate_icon 29 "Icon-App-29x29@1x.png" "logo_simple.svg"
generate_icon 58 "Icon-App-29x29@2x.png" "logo_simple.svg"
generate_icon 40 "Icon-App-40x40@1x.png" "logo_simple.svg"
generate_icon 80 "Icon-App-40x40@2x.png" "logo_simple.svg"
generate_icon 76 "Icon-App-76x76@1x.png" "logo_simple.svg"
generate_icon 152 "Icon-App-76x76@2x.png" "logo_simple.svg"
generate_icon 167 "Icon-App-83.5x83.5@2x.png" "logo_simple.svg"

# App Store icon
generate_icon 1024 "Icon-App-1024x1024@1x.png" "logo_design.svg"

echo "All icons generated in ios_icons/ directory"
echo "Copy these files to: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
