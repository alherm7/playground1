#!/bin/bash

# Script to generate iOS app icons from SVG
# Tries multiple methods to ensure compatibility

echo "Generating iOS app icons..."

# Create output directory
mkdir -p ios_icons

# Function to generate icon with fallback methods
generate_icon() {
    local size=$1
    local filename=$2
    local input_svg=$3
    
    echo "Generating ${filename} (${size}x${size})"
    
    # Method 1: Try rsvg-convert (best for SVG)
    if command -v rsvg-convert &> /dev/null; then
        echo "  Using rsvg-convert..."
        rsvg-convert -w $size -h $size -f png -o "ios_icons/${filename}" "${input_svg}"
        if [ $? -eq 0 ] && [ -s "ios_icons/${filename}" ]; then
            echo "  ✓ Success with rsvg-convert"
            return 0
        fi
    fi
    
    # Method 2: Try ImageMagick with different settings
    echo "  Trying ImageMagick with different settings..."
    
    # Try with density setting
    magick -density 300 -background transparent -size ${size}x${size} "${input_svg}" "ios_icons/${filename}"
    if [ $? -eq 0 ] && [ -s "ios_icons/${filename}" ]; then
        echo "  ✓ Success with ImageMagick (density 300)"
        return 0
    fi
    
    # Try with different background
    magick -background none -size ${size}x${size} "${input_svg}" "ios_icons/${filename}"
    if [ $? -eq 0 ] && [ -s "ios_icons/${filename}" ]; then
        echo "  ✓ Success with ImageMagick (background none)"
        return 0
    fi
    
    # Method 3: Try with inkscape if available
    if command -v inkscape &> /dev/null; then
        echo "  Trying Inkscape..."
        inkscape -w $size -h $size -o "ios_icons/${filename}" "${input_svg}"
        if [ $? -eq 0 ] && [ -s "ios_icons/${filename}" ]; then
            echo "  ✓ Success with Inkscape"
            return 0
        fi
    fi
    
    echo "  ✗ Failed to generate ${filename}"
    return 1
}

# Test with a simple SVG first
echo "Testing SVG rendering..."
if generate_icon 64 "test_icon.png" "logo_simple_fixed.svg"; then
    echo "SVG rendering works! Proceeding with all icons..."
    rm -f ios_icons/test_icon.png
else
    echo "SVG rendering failed. Let's try installing rsvg-convert..."
    echo "Run: brew install librsvg"
    exit 1
fi

# Generate all required iOS icon sizes
echo "Generating all iOS icon sizes..."

# iPhone icons
generate_icon 40 "Icon-App-20x20@2x.png" "logo_simple_fixed.svg"
generate_icon 60 "Icon-App-20x20@3x.png" "logo_simple_fixed.svg"
generate_icon 29 "Icon-App-29x29@1x.png" "logo_simple_fixed.svg"
generate_icon 58 "Icon-App-29x29@2x.png" "logo_simple_fixed.svg"
generate_icon 87 "Icon-App-29x29@3x.png" "logo_simple_fixed.svg"
generate_icon 80 "Icon-App-40x40@2x.png" "logo_simple_fixed.svg"
generate_icon 120 "Icon-App-40x40@3x.png" "logo_simple_fixed.svg"
generate_icon 120 "Icon-App-60x60@2x.png" "logo_simple_fixed.svg"
generate_icon 180 "Icon-App-60x60@3x.png" "logo_simple_fixed.svg"

# iPad icons
generate_icon 20 "Icon-App-20x20@1x.png" "logo_simple_fixed.svg"
generate_icon 40 "Icon-App-20x20@2x.png" "logo_simple_fixed.svg"
generate_icon 29 "Icon-App-29x29@1x.png" "logo_simple_fixed.svg"
generate_icon 58 "Icon-App-29x29@2x.png" "logo_simple_fixed.svg"
generate_icon 40 "Icon-App-40x40@1x.png" "logo_simple_fixed.svg"
generate_icon 80 "Icon-App-40x40@2x.png" "logo_simple_fixed.svg"
generate_icon 76 "Icon-App-76x76@1x.png" "logo_simple_fixed.svg"
generate_icon 152 "Icon-App-76x76@2x.png" "logo_simple_fixed.svg"
generate_icon 167 "Icon-App-83.5x83.5@2x.png" "logo_simple_fixed.svg"

# App Store icon (use the detailed version)
generate_icon 1024 "Icon-App-1024x1024@1x.png" "logo_design.svg"

echo ""
echo "All icons generated in ios_icons/ directory"
echo "Copy these files to: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo ""
echo "To install rsvg-convert (recommended): brew install librsvg"
