#!/bin/bash

TEX_FILE="$1"
TEMP_VALID_TEX="$(mktemp --suffix=.tex)"

# Try to compile the original file
pdflatex -interaction=nonstopmode "$TEX_FILE"

if [ $? -ne 0 ]; then # If the compilation contained errors

    # Generate a temporary tex file
    echo "Dernière version valide de la formule :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"

    # modify the original file to add the error message
    sed -i '29a\
    \\rouge{\\text{ Erreur \\LaTeX }}
    ' "$TEX_FILE"
    # Recompile the original (errorless) file to show an error message
    pdflatex -interaction=nonstopmode "$TEX_FILE"
        #konsole --noclose -e bash -c "less -R '$TEMP_VALID_TEX'"

    # Cleanup of the temporary file
    rm "$TEMP_VALID_TEX"
else

    # If the original compilation was successful
    mv "$TEX_FILE" "${TEX_FILE%.tex}_valid.tex"
fi
