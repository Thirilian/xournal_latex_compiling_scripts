# This version is not working.
# The most advanced version is wrritten to xournal_latex_wrapper-working

#!/bin/bash
TEX_FILE="$1"
TEMP_VALID_TEX="$(mktemp --suffix=.tex)"

# Try to compile the original file
pdflatex -interaction=nonstopmode "$TEX_FILE"
pdflatex_status=$?

if grep -Fq '%%%' "$TEX_FILE"; then
    pdflatex -interaction=nonstopmode "$TEMP_VALID_TEX"
elif grep -Fq '%F' "$TEX_FILE" && [ "$pdflatex_status" -ne 0 ]; then
    echo "Dernière version valide de la formule :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"
    pdflatex -interaction=nonstopmode -jobname=last_valid "$TEMP_VALID_TEX"
    rm "$TEMP_VALID_TEX"
elif [ "$pdflatex_status" -ne 0 ]; then
    echo "Dernière version valide de la formule :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"
    sed -i '29a\
    \\rouge{\\text{ Erreur \\LaTeX }}
    ' "$TEX_FILE"
    pdflatex -interaction=nonstopmode "$TEX_FILE"
    rm "$TEMP_VALID_TEX"
else
    mv "$TEX_FILE" "${TEX_FILE%.tex}_valid.tex"
fi
