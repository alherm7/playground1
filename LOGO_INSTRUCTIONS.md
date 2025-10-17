# Workout Timer App Logo Instructions

## What I've Created for You

I've created a custom logo design for your workout timer app with the following files:

1. **`logo_design.svg`** - Detailed logo with fitness elements (best for large sizes like App Store)
2. **`logo_simple.svg`** - Simplified logo optimized for small icon sizes
3. **`generate_icons.sh`** - Script to convert SVGs to all required iOS icon sizes

## Logo Design Features

- **Clock/Timer Theme**: Circular design with clock hands representing timing
- **Work/Rest Indicators**: Colored dots showing work (orange) and rest (green) phases
- **App Color Scheme**: Uses your app's purple theme (#6750A4)
- **Clean & Modern**: Simple design that works well at all sizes

## How to Generate the Icons

### Option 1: Using the Script (Recommended)

1. **Install ImageMagick** (if you don't have it):
   ```bash
   brew install imagemagick
   ```

2. **Run the generation script**:
   ```bash
   ./generate_icons.sh
   ```

3. **Copy the generated icons**:
   ```bash
   cp ios_icons/* ios/Runner/Assets.xcassets/AppIcon.appiconset/
   ```

### Option 2: Manual Generation

If you prefer to use an online tool or different software:

1. Use the `logo_simple.svg` for all sizes except 1024x1024
2. Use the `logo_design.svg` for the 1024x1024 App Store icon
3. Generate these sizes:
   - 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024
   - Include @2x and @3x variants where needed

## Required Icon Sizes

The script generates all these sizes automatically:

- **iPhone**: 20x20, 29x29, 40x40, 60x60 (with @2x and @3x variants)
- **iPad**: 20x20, 29x29, 40x40, 76x76, 83.5x83.5 (with @2x variants)
- **App Store**: 1024x1024

## File Locations

- **SVG files**: In your project root
- **Generated PNGs**: In `ios_icons/` directory
- **Final location**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Customization

If you want to modify the logo:

1. Edit the SVG files with any vector graphics editor (Inkscape, Adobe Illustrator, etc.)
2. Keep the 1024x1024 viewBox for proper scaling
3. Use your app's color scheme for consistency
4. Regenerate the PNGs using the script

## Testing

After copying the icons:

1. Clean and rebuild your iOS app
2. Install on your iPhone to see the new icon
3. The icon should appear on your home screen with the new design

## Troubleshooting

- **Icons not updating**: Try deleting the app from your device and reinstalling
- **Script permission error**: Run `chmod +x generate_icons.sh` first
- **ImageMagick not found**: Install with `brew install imagemagick`
- **Blurry icons**: Make sure you're using the correct sizes and @2x/@3x variants

The logo represents your app perfectly - a timer for workout intervals with a clean, professional look that matches your app's purple theme!
