#! /bin/zsh
pandoc $1 --output latex.tex --include-in-header preamble.tex && latexmk latex.tex -xelatex && open latex.pdf
