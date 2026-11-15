import math
import os
from PIL import Image, ImageDraw, ImageFilter

def create_financial_track_icon(size=512):
    # Create canvas with alpha
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size / 2.0
    radius = size * 0.45
    
    # Background circle with gradient
    bg_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_img)
    
    # Soft drop shadow
    shadow_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_draw.ellipse(
        [center - radius + 4, center - radius + 16, center + radius + 4, center + radius + 16],
        fill=(15, 23, 42, 140)
    )
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(12))
    img.paste(shadow_img, (0, 0), shadow_img)
    
    # Gradient background circle (Indigo to Deep Violet)
    # 0xFF4F46E5 -> 0xFF7C3AED -> 0xFF9333EA
    for r in range(int(radius), 0, -1):
        ratio = 1.0 - (r / radius)
        # Interpolate from purple edge to deep indigo center
        # Edge: #4338CA (67, 56, 202) -> Center: #6366F1 (99, 102, 241)
        red = int(67 + (99 - 67) * ratio)
        green = int(56 + (102 - 56) * ratio)
        blue = int(202 + (241 - 202) * ratio)
        bg_draw.ellipse([center - r, center - r, center + r, center + r], fill=(red, green, blue, 255))
        
    img.paste(bg_img, (0, 0), bg_img)
    
    # Inner subtle rim ring
    rim_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    rim_draw = ImageDraw.Draw(rim_img)
    rim_draw.ellipse(
        [center - radius + 3, center - radius + 3, center + radius - 3, center + radius - 3],
        outline=(255, 255, 255, 45),
        width=int(size * 0.015)
    )
    img.paste(rim_img, (0, 0), rim_img)
    
    # Foreground Graphic: Stylized Financial Track
    # 1. Rising bar chart elements in the background (Emerald & Cyan glow)
    fg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)
    
    # Draw a modern wallet card / pocket base with rounded corners
    # Wallet body
    w_width = size * 0.52
    w_height = size * 0.38
    w_x0 = center - (w_width / 2.0)
    w_y0 = center - (w_height / 2.0) + (size * 0.04)
    w_x1 = w_x0 + w_width
    w_y1 = w_y0 + w_height
    w_rad = size * 0.07
    
    # Wallet shape
    fg_draw.rounded_rectangle(
        [w_x0, w_y0, w_x1, w_y1],
        radius=w_rad,
        fill=(30, 41, 59, 230),  # Dark navy slate
        outline=(255, 255, 255, 220),
        width=int(size * 0.02)
    )
    
    # Wallet flap / card flap on top
    flap_height = w_height * 0.42
    fg_draw.rounded_rectangle(
        [w_x0 + 4, w_y0 + 4, w_x1 - 4, w_y0 + flap_height],
        radius=w_rad * 0.7,
        fill=(51, 65, 85, 240)
    )
    
    # Golden / Emerald Growth Line rising from the wallet
    # Points representing a track: from bottom-left to top-right
    p1 = (w_x0 + size * 0.08, w_y0 + flap_height + size * 0.06)
    p2 = (w_x0 + size * 0.22, w_y0 + flap_height - size * 0.02)
    p3 = (w_x0 + size * 0.34, w_y0 + flap_height + size * 0.02)
    p4 = (w_x1 + size * 0.02, w_y0 - size * 0.08)  # Rocketing up
    
    # Draw glowing track line (Emerald green: #10B981)
    glow_line = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_line)
    
    glow_draw.line([p1, p2, p3, p4], fill=(16, 185, 129, 255), width=int(size * 0.035), joint="curve")
    # Soft glow around track line
    glow_blur = glow_line.filter(ImageFilter.GaussianBlur(6))
    fg.paste(glow_blur, (0, 0), glow_blur)
    fg.paste(glow_line, (0, 0), glow_line)
    
    # Arrow head on p4
    arrow_size = size * 0.05
    fg_draw.polygon([
        p4,
        (p4[0] - arrow_size * 1.3, p4[1] + arrow_size * 0.3),
        (p4[0] - arrow_size * 0.4, p4[1] + arrow_size * 1.3),
    ], fill=(16, 185, 129, 255))
    
    # Golden Coin / Badge on the wallet clasp:
    coin_center = (w_x1 - size * 0.12, w_y0 + w_height * 0.5)
    coin_rad = size * 0.075
    
    # Coin outer shadow & ring
    fg_draw.ellipse(
        [coin_center[0] - coin_rad, coin_center[1] - coin_rad, coin_center[0] + coin_rad, coin_center[1] + coin_rad],
        fill=(245, 158, 11, 255), # Amber gold
        outline=(254, 240, 138, 255), # Pale yellow gold
        width=int(size * 0.012)
    )
    
    # Inner "Rp" or currency diamond glyph on the coin
    glyph_rad = coin_rad * 0.52
    fg_draw.ellipse(
        [coin_center[0] - glyph_rad, coin_center[1] - glyph_rad, coin_center[0] + glyph_rad, coin_center[1] + glyph_rad],
        fill=(217, 119, 6, 255)
    )
    # Currency upward check or diamond
    d_size = glyph_rad * 0.6
    fg_draw.polygon([
        (coin_center[0], coin_center[1] - d_size),
        (coin_center[0] + d_size, coin_center[1]),
        (coin_center[0], coin_center[1] + d_size),
        (coin_center[0] - d_size, coin_center[1]),
    ], fill=(255, 255, 255, 255))
    
    # 3 small coins / sparkles emerging from the top
    sparkle_coords = [
        (center - size * 0.18, w_y0 - size * 0.05, size * 0.025),
        (center - size * 0.05, w_y0 - size * 0.10, size * 0.035),
        (center + size * 0.10, w_y0 - size * 0.06, size * 0.028),
    ]
    for sx, sy, srad in sparkle_coords:
        fg_draw.ellipse([sx - srad, sy - srad, sx + srad, sy + srad], fill=(251, 191, 36, 230), outline=(255, 255, 255, 200))

    img.paste(fg, (0, 0), fg)
    return img

def export_all_icons():
    master = create_financial_track_icon(512)
    
    # Save master
    os.makedirs("assets/icon", exist_ok=True)
    master.save("assets/icon/app_icon.png")
    print("Saved master icon: assets/icon/app_icon.png")
    
    # Android mipmaps
    android_res = {
        "android/app/src/main/res/mipmap-mdpi/ic_launcher.png": (48, 48),
        "android/app/src/main/res/mipmap-hdpi/ic_launcher.png": (72, 72),
        "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": (96, 96),
        "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": (144, 144),
        "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": (192, 192),
    }
    
    for path, (w, h) in android_res.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = master.resize((w, h), Image.Resampling.LANCZOS)
        resized.save(path)
        print(f"Saved: {path} ({w}x{h})")
        
    # Web icons
    web_res = {
        "web/favicon.png": (32, 32),
        "web/icons/Icon-192.png": (192, 192),
        "web/icons/Icon-512.png": (512, 512),
        "web/icons/Icon-maskable-192.png": (192, 192),
        "web/icons/Icon-maskable-512.png": (512, 512),
    }
    
    for path, (w, h) in web_res.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = master.resize((w, h), Image.Resampling.LANCZOS)
        resized.save(path)
        print(f"Saved: {path} ({w}x{h})")

if __name__ == "__main__":
    export_all_icons()
