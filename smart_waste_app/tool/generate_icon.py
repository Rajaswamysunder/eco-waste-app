#!/usr/bin/env python3
"""
Generate Smart Waste App icons
Run: python3 tool/generate_icon.py
Requirements: pip install Pillow
"""

from PIL import Image, ImageDraw
import math
import os

def draw_recycle_symbol(draw, center, radius, color, stroke_width):
    """Draw a recycle symbol with 3 curved arrows"""
    # Draw 3 arcs
    for i in range(3):
        start_angle = i * 120 - 30
        end_angle = start_angle + 100
        
        bbox = [
            center[0] - radius,
            center[1] - radius,
            center[0] + radius,
            center[1] + radius
        ]
        
        draw.arc(bbox, start_angle, end_angle, fill=color, width=stroke_width)
        
        # Draw arrowhead at end of each arc
        end_rad = math.radians(end_angle)
        arrow_x = center[0] + radius * math.cos(end_rad)
        arrow_y = center[1] + radius * math.sin(end_rad)
        
        # Arrow triangle
        arrow_size = stroke_width * 2
        arrow_angle = end_rad + math.pi / 2
        
        points = [
            (arrow_x, arrow_y),
            (arrow_x - arrow_size * math.cos(arrow_angle - math.pi / 5),
             arrow_y - arrow_size * math.sin(arrow_angle - math.pi / 5)),
            (arrow_x - arrow_size * math.cos(arrow_angle + math.pi / 5),
             arrow_y - arrow_size * math.sin(arrow_angle + math.pi / 5)),
        ]
        draw.polygon(points, fill=color)

def create_leaf_icon(size=1024):
    """Create a simple leaf/eco icon for the waste app"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Green background circle
    margin = size * 0.05
    draw.ellipse([margin, margin, size - margin, size - margin], fill='#4CAF50')
    
    # Draw a stylized leaf
    center_x, center_y = size // 2, size // 2
    leaf_width = size * 0.35
    leaf_height = size * 0.5
    
    # Leaf body (ellipse rotated)
    leaf_bbox = [
        center_x - leaf_width,
        center_y - leaf_height * 0.6,
        center_x + leaf_width,
        center_y + leaf_height * 0.6
    ]
    
    # Draw main leaf shape
    points = []
    for i in range(100):
        t = i / 100 * 2 * math.pi
        # Leaf shape equation
        x = center_x + leaf_width * 0.8 * math.sin(t) * (1 if t < math.pi else -1)
        # Make it pointed at top
        if t < math.pi:
            y = center_y - leaf_height * 0.5 * (1 - abs(math.sin(t)))
        else:
            y = center_y + leaf_height * 0.5 * (1 - abs(math.sin(t)))
        
        # Simpler leaf shape
        angle = t - math.pi / 2
        r = leaf_width * 0.6 * (1 + 0.3 * math.cos(2 * angle))
        x = center_x + r * math.cos(angle)
        y = center_y + r * math.sin(angle) * 1.3
        points.append((x, y))
    
    draw.polygon(points, fill='white')
    
    # Leaf vein (center line)
    vein_start = (center_x, center_y - leaf_height * 0.4)
    vein_end = (center_x, center_y + leaf_height * 0.3)
    draw.line([vein_start, vein_end], fill='#4CAF50', width=int(size * 0.02))
    
    # Small branch veins
    for i, offset in enumerate([-0.15, 0, 0.15]):
        y = center_y + leaf_height * offset
        branch_len = leaf_width * 0.25 * (1 - abs(offset) * 1.5)
        draw.line([
            (center_x - branch_len, y - branch_len * 0.3),
            (center_x, y),
        ], fill='#4CAF50', width=int(size * 0.015))
        draw.line([
            (center_x + branch_len, y - branch_len * 0.3),
            (center_x, y),
        ], fill='#4CAF50', width=int(size * 0.015))
    
    return img

def create_recycle_icon(size=1024):
    """Create a recycle symbol icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Green background with rounded corners (circle)
    margin = size * 0.02
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=size * 0.2,
        fill='#4CAF50'
    )
    
    # Draw recycle symbol
    center = (size // 2, size // 2)
    radius = size * 0.32
    stroke_width = int(size * 0.06)
    
    draw_recycle_symbol(draw, center, radius, 'white', stroke_width)
    
    return img

def create_simple_waste_icon(size=1024):
    """Create a simple, modern waste management icon"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Green background with rounded corners
    margin = int(size * 0.02)
    corner_radius = int(size * 0.22)
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=corner_radius,
        fill='#4CAF50'
    )
    
    center_x, center_y = size // 2, size // 2
    
    # Draw a stylized bin/container
    bin_width = size * 0.45
    bin_height = size * 0.5
    bin_top = center_y - bin_height * 0.35
    bin_bottom = center_y + bin_height * 0.45
    
    # Bin body (trapezoid shape)
    top_width = bin_width * 0.9
    bottom_width = bin_width * 0.75
    
    bin_points = [
        (center_x - top_width / 2, bin_top),
        (center_x + top_width / 2, bin_top),
        (center_x + bottom_width / 2, bin_bottom),
        (center_x - bottom_width / 2, bin_bottom),
    ]
    draw.polygon(bin_points, fill='white')
    
    # Bin lid
    lid_height = size * 0.08
    lid_top = bin_top - lid_height
    lid_width = top_width * 1.15
    
    lid_points = [
        (center_x - lid_width / 2, lid_top),
        (center_x + lid_width / 2, lid_top),
        (center_x + top_width / 2 * 1.05, bin_top),
        (center_x - top_width / 2 * 1.05, bin_top),
    ]
    draw.polygon(lid_points, fill='white')
    
    # Lid handle
    handle_width = size * 0.12
    handle_height = size * 0.04
    handle_top = lid_top - handle_height
    draw.rounded_rectangle(
        [center_x - handle_width / 2, handle_top,
         center_x + handle_width / 2, lid_top],
        radius=int(size * 0.02),
        fill='white'
    )
    
    # Recycle arrows on bin (smaller)
    arrow_center = (center_x, center_y + size * 0.08)
    arrow_radius = size * 0.13
    arrow_stroke = int(size * 0.025)
    draw_recycle_symbol(draw, arrow_center, arrow_radius, '#4CAF50', arrow_stroke)
    
    return img

def create_foreground_icon(size=1024):
    """Create foreground icon for adaptive icons (transparent background)"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center_x, center_y = size // 2, size // 2
    
    # Draw the same waste bin but sized for adaptive icon safe zone
    # Safe zone is typically 66% of the icon
    scale = 0.6
    
    bin_width = size * 0.45 * scale
    bin_height = size * 0.5 * scale
    bin_top = center_y - bin_height * 0.35
    bin_bottom = center_y + bin_height * 0.45
    
    top_width = bin_width * 0.9
    bottom_width = bin_width * 0.75
    
    bin_points = [
        (center_x - top_width / 2, bin_top),
        (center_x + top_width / 2, bin_top),
        (center_x + bottom_width / 2, bin_bottom),
        (center_x - bottom_width / 2, bin_bottom),
    ]
    draw.polygon(bin_points, fill='white')
    
    lid_height = size * 0.08 * scale
    lid_top = bin_top - lid_height
    lid_width = top_width * 1.15
    
    lid_points = [
        (center_x - lid_width / 2, lid_top),
        (center_x + lid_width / 2, lid_top),
        (center_x + top_width / 2 * 1.05, bin_top),
        (center_x - top_width / 2 * 1.05, bin_top),
    ]
    draw.polygon(lid_points, fill='white')
    
    handle_width = size * 0.12 * scale
    handle_height = size * 0.04 * scale
    handle_top = lid_top - handle_height
    draw.rounded_rectangle(
        [center_x - handle_width / 2, handle_top,
         center_x + handle_width / 2, lid_top],
        radius=int(size * 0.015),
        fill='white'
    )
    
    # Small recycle symbol
    arrow_center = (center_x, center_y + size * 0.05)
    arrow_radius = size * 0.08
    arrow_stroke = int(size * 0.018)
    
    # Draw simple arrows for recycle
    for i in range(3):
        start_angle = i * 120 - 30
        end_angle = start_angle + 100
        
        bbox = [
            arrow_center[0] - arrow_radius,
            arrow_center[1] - arrow_radius,
            arrow_center[0] + arrow_radius,
            arrow_center[1] + arrow_radius
        ]
        
        draw.arc(bbox, start_angle, end_angle, fill='#4CAF50', width=arrow_stroke)
    
    return img

def main():
    # Ensure output directory exists
    os.makedirs('assets/icon', exist_ok=True)
    
    print("Generating Smart Waste App icons...")
    
    # Create main app icon
    icon = create_simple_waste_icon(1024)
    icon.save('assets/icon/app_icon.png', 'PNG')
    print("✓ Created: assets/icon/app_icon.png")
    
    # Create foreground for adaptive icons
    foreground = create_foreground_icon(1024)
    foreground.save('assets/icon/app_icon_foreground.png', 'PNG')
    print("✓ Created: assets/icon/app_icon_foreground.png")
    
    print("")
    print("Now run the following commands:")
    print("  cd smart_waste_app")
    print("  flutter pub get")
    print("  dart run flutter_launcher_icons")
    print("")
    print("This will generate icons for iOS and Android.")

if __name__ == '__main__':
    main()
