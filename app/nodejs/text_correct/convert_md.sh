outF="views/pages/about.ejs"
cat views/partials/header.html > $outF
sed -e 's/views\////g' README.md > README1.md
pandoc -f markdown README1.md >> $outF
cat views/partials/footer.html >> $outF
rm README1.md

