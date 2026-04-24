#!/bin/bash
TEX_FILE="$1"
TEMP_VALID_TEX="$(mktemp --suffix=.tex)"

# Try to compile the original file
pdflatex -interaction=nonstopmode "$TEX_FILE"
pdflatex_status=$?

if grep -Fq '%%%' "$TEX_FILE"; then #If %%% was written to go to error-display mode
    pdflatex -interaction=nonstopmode "$TEX_FILE"

elif grep -Fq '%F' "$TEX_FILE" && [ "$pdflatex_status" -ne 0 ]; then #If %F was written go to fast compile mode
    echo "Last valid version of the formula :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"

    # Compile the temporary file ignoring errors
    pdflatex -interaction=nonstopmode -jobname=last_valid "$TEMP_VALID_TEX"

    # Clean up the temporary file
    rm "$TEMP_VALID_TEX"

elif [ "$pdflatex_status" -ne 0 ]; then # If the compilation contained errors and no option was input
    echo "Last valid version of the formula :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"

    # modify the original (compiled) file to add the error message
    #See the note and modify accordingly
    awk 'prev && /\\\)/ { printf "%s%s\n", prev, " {\\color{red} \\text{ Erreur \\LaTeX }}"; print; prev=""; next } { if (prev) print prev; prev=$0 } END { if (prev) print prev }' "$TEX_FILE" > "$TEX_FILE.tmp" && mv "$TEX_FILE.tmp" "$TEX_FILE"

    # Recompile the original (errorless) file to show an error message
    pdflatex -interaction=nonstopmode "$TEX_FILE"
    # Clean up the temporary file
    rm "$TEMP_VALID_TEX"

else
    # The formula doesn't contain errors, save it
    mv "$TEX_FILE" "${TEX_FILE%.tex}_valid.tex"
fi
