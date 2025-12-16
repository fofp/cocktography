#!/usr/bin/env python3
"""
Build script for Cocktography extension
Converts dicktionary text files to embedded JavaScript
"""
import json
import os

def build_dicktionaries():
    """Convert text files to dicktionaries.js"""

    # Read all three dicktionaries
    with open('dicktionaries/kontol_chodes.txt', 'r', encoding='utf-8') as f:
        kontol_chodes = f.read()

    with open('dicktionaries/cock_bytes.txt', 'r', encoding='utf-8') as f:
        cock_bytes = f.read()

    with open('dicktionaries/rodsetta_stone.txt', 'r', encoding='utf-8') as f:
        rodsetta_stone = f.read()

    # Create JavaScript file with embedded data
    js_content = f'''/**
 * Embedded Cocktography Dicktionaries
 * Converted from text files to avoid CSP/fetch issues in Firefox content scripts
 */

const DICKTIONARIES = {{
    kontol_chodes: {json.dumps(kontol_chodes)},
    cock_bytes: {json.dumps(cock_bytes)},
    rodsetta_stone: {json.dumps(rodsetta_stone)}
}};
'''

    with open('dicktionaries.js', 'w', encoding='utf-8') as f:
        f.write(js_content)

    print("✓ dicktionaries.js generated successfully!")

if __name__ == '__main__':
    build_dicktionaries()
