#!/bin/bash

echo "🌿 Creating FloraTale App Icon..."
echo ""

# Create assets directory
mkdir -p assets/icon

echo "📁 Created assets/icon directory"
echo ""

# Instructions for creating the icon
cat << 'EOF'
🎨 To create your FloraTale app icon:

1. Open any image editor (Photoshop, GIMP, Canva, etc.)
2. Create a new file: 1024x1024 pixels
3. Design your icon with:
   • Background: Gradient from #2D5016 to #7CB518 (green tones)
   • Center: White plant/leaf icon (local_florist style)
   • Bottom accent: Brown rectangle (#8B4513 with 30% opacity)
   • Corners: Rounded (about 15-20% radius)
   • Top-right: Small white circle for shine effect

4. Save as: assets/icon/floratale_icon.png

5. Then run:
   flutter pub run flutter_launcher_icons:main

📱 Your icon will be automatically generated for:
   • Android: All screen densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
   • iOS: All icon sizes (29pt, 40pt, 60pt, 76pt, 83.5pt)

🎯 Icon Design Tips:
   • Keep it simple and recognizable
   • Use the Nigerian green color scheme
   • Make sure it works in small sizes (16x16)
   • Test on both light and dark backgrounds

🌿 Cultural Elements to Include:
   • Plant motifs (baobab, moringa, etc.)
   • Nigerian green and brown colors
   • Clean, modern design
   • Rounded corners for friendly feel
EOF

echo ""
echo "📋 Copy these instructions to create your icon!"
echo "🔧 After creating the PNG, run: flutter pub run flutter_launcher_icons:main"

