#!/usr/bin/env python3
"""
Package the Cocktography extension as an XPI file
"""
import zipfile
import os

def build_xpi():
    """Create XPI package with proper forward slashes"""

    xpi_path = '../cocktography-irccloud.xpi'

    with zipfile.ZipFile(xpi_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add root files
        files = [
            'manifest.json',
            'popup.html',
            'popup.js',
            'background.js',
            'content.js',
            'content.css',
            'cpi.js',
            'dicktionaries.js'
        ]

        for file in files:
            if os.path.exists(file):
                zipf.write(file, file)
                print(f"  Added: {file}")

        # Add icons directory
        if os.path.exists('icons'):
            for icon in os.listdir('icons'):
                if icon.endswith('.png'):
                    icon_path = f'icons/{icon}'
                    zipf.write(icon_path, icon_path)
                    print(f"  Added: {icon_path}")

    print(f"\n✓ XPI created: {xpi_path}")

if __name__ == '__main__':
    build_xpi()
