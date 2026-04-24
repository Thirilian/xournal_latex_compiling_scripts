# This version doesn't work
#!/bin/bash
TEX_FILE="$1"
TEMP_VALID_TEX="$(mktemp --suffix=.tex)"

# Try to compile the original file
pdflatex -interaction=nonstopmode "$TEX_FILE"

if grep -Fq '%%%' "$TEX_FILE"; then #If %%% was written to go to error-display mode
    pdflatex -interaction=nonstopmode "$TEMP_VALID_TEX"
elif grep -Fq '%F' "$TEX_FILE" && [ $? -ne 0 ]; then #If %F was written to go to fast compile mode
    # Générer un document contenant la dernière version valide
    echo "Dernière version valide de la formule :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"

    # Compiler la dernière version valide
    pdflatex -interaction=nonstopmode -jobname=last_valid "$TEMP_VALID_TEX"

    # Nettoyer
    rm "$TEMP_VALID_TEX"
elif [ $? -ne 0 ]; then # If the compilation contained errors
    #konsole --noclose -e bash -c 'echo "coucou"'
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
