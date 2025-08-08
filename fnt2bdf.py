#!/usr/bin/env python3
import sys
import json
import os
from pathlib import Path


def load_cp437_to_unicode():
    """Load CP437 to Unicode mapping from JSON file."""
    with open('cp437_to_unicode.json', 'r', encoding='utf-8') as f:
        return json.load(f)


def reverse_bits(byte, ignore_half_dot):
    """Reverse bits in a byte, optionally ignoring the half-dot shift."""
    if ignore_half_dot:
        return (((byte & 0x40) >> 5) |
                ((byte & 0x20) >> 3) |
                ((byte & 0x10) >> 1) |
                ((byte & 0x08) << 1) |
                ((byte & 0x04) << 3) |
                ((byte & 0x02) << 5) |
                ((byte & 0x01) << 7))
    
    return (((byte & 0x80) >> 7) |
            ((byte & 0x40) >> 5) |
            ((byte & 0x20) >> 3) |
            ((byte & 0x10) >> 1) |
            ((byte & 0x08) << 1) |
            ((byte & 0x04) << 3) |
            ((byte & 0x02) << 5) |
            ((byte & 0x01) << 7))


def generate_glyphs(file_name, glyph_width, glyph_height, glyph_count, code_mapper=None):
    """Generate glyph data from font file."""
    result = []
    
    with open(file_name, 'rb') as f:
        glyph_data = f.read()
    
    glyph_ascent = glyph_height
    glyph_descent = glyph_height - glyph_ascent
    glyph_width_bytes = glyph_width // 8
    bytes_per_glyph = glyph_width_bytes * glyph_height
    
    offset = 0
    for i in range(glyph_count):
        code = code_mapper(i) if code_mapper else i
        
        result.append(f"STARTCHAR U+{code:04X}")
        result.append(f"ENCODING {code}")
        result.append(f"SWIDTH {glyph_width * 1000} 0")
        result.append(f"DWIDTH {glyph_width} 0")
        result.append(f"BBX {glyph_width} {glyph_height} 0 {-glyph_descent}")
        result.append("BITMAP")
        
        for y in range(glyph_height):
            hex_bytes = []
            for x in range(glyph_width_bytes):
                # Row first processing
                byte = glyph_data[offset + y * glyph_width_bytes + x]
                hex_bytes.append(f"{byte:02X}")
            result.append(''.join(hex_bytes))
        
        # Move to next glyph
        offset += glyph_width_bytes * glyph_height
        result.append("ENDCHAR")
    
    return '\n'.join(result)


def generate_font(font_name, font_width, font_height, font_ascent=None, font_descent=0, glyphs=None):
    """Generate complete BDF font from glyph specifications."""
    if glyphs is None:
        glyphs = []
    
    result = []
    result.append("STARTFONT 2.1")
    result.append(f"FONT {font_name}")
    result.append(f"SIZE {font_height} 72 72")
    result.append(f"FONTBOUNDINGBOX {font_width} {font_height} 0 {-font_descent}")
    result.append(f"SWIDTH {font_width * 1000} 0")
    result.append(f"DWIDTH {font_width} 0")
    result.append("STARTPROPERTIES 2")
    result.append(f"FAMILY_NAME {font_name}")
    result.append(f"FONT_ASCENT {font_ascent if font_ascent is not None else font_height - font_descent}")
    result.append(f"FONT_DESCENT {font_descent}")
    result.append("ENDPROPERTIES")
    
    total_chars = sum(glyph['glyph_count'] for glyph in glyphs)
    result.append(f"CHARS {total_chars}")
    
    for glyph in glyphs:
        glyph_data = generate_glyphs(
            glyph['file_name'],
            glyph['glyph_width'],
            glyph['glyph_height'],
            glyph['glyph_count'],
            glyph.get('code_mapper')
        )
        result.append(glyph_data)
    
    result.append("ENDFONT")
    return '\n'.join(result)


def main():
    # Parse command line arguments
    eng_font_file = sys.argv[1] if len(sys.argv) > 1 else 'eng.fnt'
    han_font_file = sys.argv[2] if len(sys.argv) > 2 else 'han.fnt'
    bdf_file = sys.argv[3] if len(sys.argv) > 3 else '8x4x4.bdf'
    font_name = sys.argv[4] if len(sys.argv) > 4 else Path(bdf_file).stem
    
    # Load CP437 mapping
    cp437_to_unicode = load_cp437_to_unicode()
    
    # Constants
    PUA = 0xf600
    
    # Code mappers
    def eng_code_mapper(index):
        return ord(cp437_to_unicode[index])
    
    def han_code_mapper(index):
        return PUA + index
    
    # Generate font
    font_data = generate_font(
        font_name=font_name,
        font_width=8,
        font_height=16,
        glyphs=[
            {
                'file_name': eng_font_file,
                'glyph_width': 8,
                'glyph_height': 16,
                'glyph_count': 256,
                'code_mapper': eng_code_mapper
            },
            {
                'file_name': han_font_file,
                'glyph_width': 16,
                'glyph_height': 16,
                'glyph_count': 360, # 8*(19+1) + 4*(21+1) + 4*(27+1)
                'code_mapper': han_code_mapper
            }
        ]
    )
    
    # Write output file
    with open(bdf_file, 'w', encoding='utf-8') as f:
        f.write(font_data)


if __name__ == '__main__':
    main()
