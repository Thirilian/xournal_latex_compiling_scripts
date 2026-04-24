#!/bin/bash
TEX_FILE="$1"

pdflatex -interaction=nonstopmode "$TEX_FILE"
if [ $? -ne 0 ]; then
    FALLBACK_TEX="$(mktemp --suffix=.tex)"
    cat > "$FALLBACK_TEX" <<EOF
\documentclass{standalone}
\usepackage{xcolor}
\begin{document}
{\Huge\color{red} Invalid LaTeX formula}
\end{document}
EOF
    pdflatex -interaction=nonstopmode -jobname=tex "$FALLBACK_TEX"
    rm "$FALLBACK_TEX"
fi
