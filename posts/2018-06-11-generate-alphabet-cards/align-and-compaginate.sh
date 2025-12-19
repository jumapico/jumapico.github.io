#!/bin/bash
set -e

# generate inkscape command
cmd=""
for i in {1..6}; do
    cmd=" $cmd --select=r$i --select=t$i"
    cmd=" $cmd --verb=AlignVerticalCenter"
    cmd=" $cmd --verb=AlignHorizontalCenter"
    cmd=" $cmd --verb=EditDeselect"
done
cmd=" $cmd --verb=FileSave"
cmd=" $cmd --verb=FileQuit"

# generate al pages (pdf)
for character in {A..Z} Ñ {0..9}; do
    cat base.svg | sed -e 's#>PLACEHOLDER</text>#>'$character'</text>#g' > page-$character.svg
    inkscape -f page-$character.svg $cmd
    rsvg-convert -f pdf -o page-$character.pdf page-$character.svg
done

# concatenate
pdfunite page-*.pdf output.pdf
