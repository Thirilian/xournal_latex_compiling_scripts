#!/bin/bash
TEX_FILE="$1"
TEMP_VALID_TEX="$(mktemp --suffix=.tex)"

# Essayer de compiler le fichier LaTeX d'origine
pdflatex -interaction=nonstopmode "$TEX_FILE"

if [ $? -ne 0 ]; then
    # Générer un document contenant la dernière version valide
    echo "Dernière version valide de la formule :" > "$TEMP_VALID_TEX"
    cat "$TEX_FILE" >> "$TEMP_VALID_TEX"

    # Ajouter le message d'erreur
    echo "\\\\[1em]" >> "$TEMP_VALID_TEX"  # Ajoute un petit espace vertical
    echo "{\\Huge\\color{red} Erreur}" >> "$TEMP_VALID_TEX"

    # Compiler la dernière version valide
    pdflatex -interaction=nonstopmode -jobname=last_valid "$TEMP_VALID_TEX"

    # Nettoyer
    rm "$TEMP_VALID_TEX"
else
    # Si la compilation réussit, sauvegarder le fichier
    mv "$TEX_FILE" "${TEX_FILE%.tex}_valid.tex"
fi
