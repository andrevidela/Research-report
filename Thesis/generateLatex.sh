pandoc index.md --output latex.tex --include-in-header preamble.tex && latexmk latex.tex -xelatex && open latex.pdf
