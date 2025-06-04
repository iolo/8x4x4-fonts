Function fontforge {
    & "${env:ProgramFiles(x86)}\FontForgeBuilds\fontforge.bat" $args
}

Function bitsnpicas {
    & "${env:JAVA_HOME}\bin\java.exe" -jar "$HOME\apps\bitsnpicas\BitsNPicas.jar" $args
}

Function buildFont($eng, $kor, $out) {
    node fnt2bdf.js "$eng" "$kor" "$out.bdf"
    bitsnpicas convertbitmap -f ttf -o temp.ttf "$out.bdf"
    fontforge --lang=py --script generate_hangul_syllables.py "$out"
    if (Test-Path "./FontPatcher/font-patcher") {
      fontforge --lang=py --script ./FontPatcher/font-patcher --careful --complete "$out.ttf"
    }
    rm temp.ttf
}

rm *.bdf
rm *.sfd
rm *.ttf
rm *.otf
rm *.woff
rm *.woff2

buildFont "src/eng.fnt" "src/dkby.fnt" "Dkby_8x4x4"
buildFont "src/eng_sans.fnt" "src/dkby.fnt" "Dkby_8x4x4_sans"
buildFont "src/eng.fnt" "src/hanme.fnt" "Hanme_8x4x4"
buildFont "src/eng_sans.fnt" "src/hanme.fnt" "Hanme_8x4x4_sans"
buildFont "src/eng.fnt" "src/iyagi.fnt" "Iyagi_8x4x4"
buildFont "src/eng_sans.fnt" "src/iyagi.fnt" "Iyagi_8x4x4_sans"
buildFont "src/eng.fnt" "src/serif.fnt" "Serif_8x4x4"
buildFont "src/eng_sans.fnt" "src/sans.fnt" "Sans_8x4x4"
