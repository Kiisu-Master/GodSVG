count=$(find *.po -maxdepth 1 -type f | wc -l) # Get po file count.
printf "\nFound $count po files. Starting update..."
for file in ./*.po; do
    printf "\n\n$count files left.\nUpdating $file: "
    let count--
    msgmerge --update --quiet --verbose --backup=off $file Translations.pot
    if [ "$?" != "0" ]; then # Exit loop on error.
        printf "\nUpdating failed, exiting."
        exit
    fi
done
printf "\nUpdating completed!"
