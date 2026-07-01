#!/bin/bash
TEX_FILE="$1"
TEMP_VALID_TEX="$(mktemp --suffix=.tex)"

if grep -Fq '%txt' "$TEX_FILE"; then # if %txt was inserted to start with text mode, 
    TEX_TEXT="$TEX_FILE" # Branch to text mode related variable
    sed -i -E '/^[ \t]*\\\($/d; /^[ \t]*\\\)$/d' "$TEX_TEXT" # remove \( \displaystyle \) to prevent math mode
    sed -i -E '/^[ \t]*\\displaystyle$/d' "$TEX_TEXT"
    sed -i -E '/^[ \t]*\%txt$/d' "$TEX_TEXT" # remove "%txt" from the branch although not so useful
    #konsole --noclose -e bash -c "less -R '$TEX_TEXT'"
    pdflatex -interaction=batchmode "$TEX_TEXT" > /dev/null 2>&1
    
elif grep -Fq '%minted' "$TEX_FILE" ; then # If %minted was written
    TEX_MINTED="$TEX_FILE" # branch to code mode
    sed -i '/\\displaystyle/{N;s/\\displaystyle\n//;}' "$TEX_MINTED"
    sed -i '/%minted/{N;s/%minted//;}' "$TEX_MINTED" #make evry ajustment to have minted instead of math env
    sed -z -E 's/\(\n[ \t]+/\begin{lstlisting}\n/g' -i "$TEX_MINTED"
    sed -i 's/\\)/\\end{lstlisting}/g' "$TEX_MINTED"
    sed -i 's/0.999\\maxdimen/15cm/g' "$TEX_MINTED" #ajust sheet size
    pdflatex -interaction=batchmode "$TEX_MINTED" > /dev/null 2>&1
    
else
    # if no option were detected and no compilation yet, try to compile the original file
    pdflatex -interaction=batchmode "$TEX_FILE" > /dev/null 2>&1
fi
    pdflatex_status=$?

if grep -Fq '%%%' "$TEX_FILE"; then #If %%% was written to go to error-display mode
    pdflatex -interaction=nonstopmode "$TEX_FILE"
    if grep -Fq '%%%%' "$TEX_FILE"; then
        konsole --noclose -e bash -c "less -R '$TEX_FILE'"
    fi
fi

if [ "$pdflatex_status" -ne 0 ]; then # If the compilation contained errors and no option was input
    echo "Last valid version of the formula :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"

    # modify the original (compiled) file to add the error message
            # if TEX_FILE contains \) (classic, math mode)
    if grep -Fq '\)' "$TEX_FILE"; then
        awk 'prev && /\\\)/ { printf "%s%s\n", prev, " {\\color{red} \\text{ Erreur \\LaTeX }}"; print; prev=""; next } { if (prev) print prev; prev=$0 } END { if (prev) print prev }' "$TEX_FILE" > "$TEX_FILE.tmp" && mv "$TEX_FILE.tmp" "$TEX_FILE"
    else     # else (text mode or code mode), anchor the error message on the scontent env directly
        awk '{ if ($0 ~ /\\end\{scontents\}/) { print " {\\color{red} \\text{ Erreur \\LaTeX }}" } print }' "$TEX_FILE" > "$TEX_FILE.tmp" && mv "$TEX_FILE.tmp" "$TEX_FILE"
    fi
    
    # Recompile the original (errorless) file to show an error message
    pdflatex -interaction=nonstopmode "$TEX_FILE"

    # if no PDF output was produced, notify the user and compile a message instead of the formula
    if [ ! -f "${TEX_FILE%.tex}.pdf" ]; then
        FALLBACK_TEX="$(mktemp --suffix=.tex)"
        cat > "$FALLBACK_TEX" <<EOF
        \documentclass{standalone}
        \usepackage{xcolor}
        \begin{document}
        {\Huge\color[RGB]{0, 150, 0}{Invalid file (forgotten \})}}
        \end{document}
EOF
        pdflatex -interaction=nonstopmode -jobname=tex "$FALLBACK_TEX"
        rm "$FALLBACK_TEX"
    fi
    
    # Clean up the temporary file
    rm "$TEMP_VALID_TEX"

else
    # The formula doesn't contain errors, save it
    mv "$TEX_FILE" "${TEX_FILE%.tex}_valid.tex"
fi
