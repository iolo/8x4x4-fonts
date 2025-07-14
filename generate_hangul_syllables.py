#!/usr/bin/fontforge -script

import fontforge
import sys

name = sys.argv[1]

f = fontforge.open('temp.ttf')

NUM_CHO = 19 # no filler
NUM_JUNG = 21 # no filler
NUM_JONG = 28 # with filter

CHO_KIND = 8
JUNG_KIND = 4
JONG_KIND = 4

# 자모 초성/중성/종성
JAMO_CHO = 0x1100
JAMO_JUNG = 0x1161
JAMO_JONG = 0x11a8

# 가~힣
KOR = 0xac00
# PUA(0xe000~0xf8ff) 영역에 조합용 한글 초성/중성/종성 글립이 들어있음
#PUA = 0xe010
# conflict with nerd font glyphs
# https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
PUA = 0xf600

PUA_CHO = PUA # 초성 글립(3종류)
PUA_JUNG = PUA_CHO + (NUM_CHO + 1) * CHO_KIND # 중성 글립(1종류)
PUA_JONG = PUA_CHO + (NUM_CHO + 1) * CHO_KIND + (NUM_JUNG + 1) * JUNG_KIND # 종성 글립(1종류)

#                        ㅏ ㅐ ㅑ ㅒ ㅓ ㅔ ㅕ ㅖ ㅗ ㅘ ㅙ ㅚ ㅛ ㅜ ㅝ ㅞ ㅟ ㅠ ㅡ ㅢ ㅣ
cho_kind_without_jong = [0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 3, 1, 2, 4, 4, 4, 2, 1, 3, 0];
cho_kind_with_jong    = [5, 5, 5, 5, 5, 5, 5, 5, 6, 7, 7, 7, 6, 6, 7, 7, 7, 6, 6, 7, 5];
jong_kind_by_jung     = [0, 2, 0, 2, 1, 2, 1, 2, 3, 0, 2, 1, 3, 3, 1, 2, 1, 3, 3, 1, 1];

code = JAMO_CHO
for cho in range(NUM_CHO):
    c = f.createChar(code)
    c.addReference(fontforge.nameFromUnicode(PUA_CHO + cho))
    code += 1

code = JAMO_JUNG
for jung in range(NUM_JUNG):
    c = f.createChar(code)
    c.addReference(fontforge.nameFromUnicode(PUA_JUNG + jung))
    code += 1

code = JAMO_JONG
for jong in range(NUM_JONG):
    c = f.createChar(code)
    c.addReference(fontforge.nameFromUnicode(PUA_JONG + jong))
    code += 1

code = KOR
for cho in range(NUM_CHO):
    for jung in range(NUM_JUNG):
        for jong in range(NUM_JONG):
            if jong == 0: # no jonseong
                cho_kind = cho_kind_without_jong[jung];
                if cho == 0 or cho == 15: # ㄱ, ㅋ
                    jung_kind = 0
                else:
                    jung_kind = 1
            else: # has jongseong
                cho_kind = cho_kind_with_jong[jung];
                if cho == 0 or cho == 15: # ㄱ, ㅋ
                    jung_kind = 2
                else:
                    jung_kind = 3
            jong_kind = jong_kind_by_jung[jung];
            cho_code = PUA_CHO + (NUM_CHO + 1) * cho_kind + cho + 1 #unicode choseong has no filler
            jung_code = PUA_JUNG + (NUM_JUNG + 1) * jung_kind + jung + 1 # unicode jungseong has no filler
            jong_code = PUA_JONG + NUM_JONG * jong_kind + jong # unicode jongseong already has filler
            #print(f'cho={cho},jung={jung},jong={jong}->code={code:04x},char={chr(code)}')
            c = f.createChar(code)
            c.addReference(fontforge.nameFromUnicode(cho_code))
            c.addReference(fontforge.nameFromUnicode(jung_code))
            c.addReference(fontforge.nameFromUnicode(jong_code))
            code += 1

f.os2_version = 4
f.os2_family_class = 49
f.os2_codepages = (0x00200000, 0x00000000)
f.os2_unicoderanges = (0x10000001, 0x11000000, 0x00000000, 0x00000000)

f.generate(f'{name}.ttf', flags=('short-post'))
f.generate(f'{name}.otf', flags=('short-post'))
f.generate(f'{name}.woff')
f.generate(f'{name}.woff2')

