const fs = require('fs');
const path = require('path');

function generateGlyphs({ fileName, glyphWidth, glyphHeight, glyphCount, codeBegin = 0 }) {
  const result = [];
  const glyphData = fs.readFileSync(fileName);
  const glyphAscent = glyphHeight;
  const glyphDescent = glyphHeight - glyphAscent;
  const glyphWidthBytes = glyphWidth / 8;
  const bytesPerGlyph = glyphWidthBytes * glyphHeight;
  for (let i = 0, offset = 0; i < glyphCount; i++) {
    const code = codeBegin + i;
    result.push(`STARTCHAR U+${code.toString(16).toUpperCase().padStart(4, `0`)}`);
    result.push(`ENCODING ${code}`);
    result.push(`SWIDTH ${glyphWidth * 1000} 0`);
    result.push(`DWIDTH ${glyphWidth} 0`);
    result.push(`BBX ${glyphWidth} ${glyphHeight} ${-glyphDescent}`);
    result.push(`BITMAP`);
    for (let y = 0, n = offset; y < glyphHeight; y++) {
      const hex = [];
      for (let x = 0; x < glyphWidthBytes; x++) {
        hex.push(glyphData[offset++].toString(16).toUpperCase().padStart(2, '0'));
      }
      result.push(hex.join(''));
    }
    result.push(`ENDCHAR`);
  }
  return result.join('\n');
}

function generateFont({ fontName, fontWidth, fontHeight, fontAscent, fontDescent = 0, glyphs }) {
  const result = [];
  result.push('STARTFONT 2.1');
  result.push(`FONT ${fontName}`);
  //-${fontFoundary}-${fontName}-medium-r-normal--${glyphHeight}-${fontHeight*10}-72-72-c-${fontWidth*10}-iso10646-1
  result.push(`SIZE ${fontHeight} 72 72`);
  result.push(`FONTBOUNDINGBOX ${fontWidth} ${fontHeight} 0 ${-fontDescent}`);
  result.push(`SWIDTH ${fontWidth * 1000} 0`);
  result.push(`DWIDTH ${fontWidth} 0`);
  result.push(`STARTPROPERTIES 2`);
  result.push(`FAMILY_NAME ${fontName}`);
  result.push(`FONT_ASCENT ${fontAscent ?? fontHeight - fontDescent}`);
  result.push(`FONT_DESCENT ${fontDescent}`);
  result.push(`ENDPROPERTIES`);
  result.push(`CHARS ${glyphs.reduce((sum, glyph) => sum + glyph.glyphCount, 0)}`);
  for (const glyph of glyphs) {
    result.push(generateGlyphs(glyph));
  }
  result.push('ENDFONT');
  return result.join('\n');
}

const engFontFile = process.argv[2] ?? 'eng.fnt';
const hanFontFile = process.argv[3] ?? 'han.fnt';
const bdfFile= process.argv[4] ?? '8x4x4.bdf';
const fontName = process.argv[5] ?? path.parse(bdfFile).name;

fs.writeFileSync(bdfFile, generateFont({
  fontName,
  fontWidth: 8,
  fontHeight: 16,
  glyphs: [
    { fileName: engFontFile, glyphWidth: 8, glyphHeight: 16, glyphCount: 256, codeBegin: 0 },
    { fileName: hanFontFile, glyphWidth: 16, glyphHeight: 16, glyphCount: 360, codeBegin: 0xe010 }, // (cho 19+1)*8 + (jung 21+1)*4 + (jong 27+1)*4; +1 for filler; 0xE010=PUA+
  ],
}));
