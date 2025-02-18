#!/bin/bash

_local_check() {

    local tableau
    tableau=$(find "$GASH_MISSIONS" -name "tableau" -type f)

    # _local_check that file exists in "coffre"
    if [ ! -f "$GASH_COFFRE/tableau" ]
    then
        echo "Il n'y a pas de tableau dans le coffre !"
        return 1
    fi

    # _local_check that file still exists in "Premier_etage"
    if [ ! -f "$GASH_HOME/Chateau/Donjon/Premier_etage/tableau" ]
    then
        echo "Il n'y a plus de tableau au premier étage du donjon !"
        return 1
    fi

    # _local_check that the files are the same
    if ! diff -q "$tableau" "$GASH_HOME/Chateau/Donjon/Premier_etage/tableau"
    then
        echo "Les deux tableaux sont différents !"
        return 1
    fi
    if ! diff -q "$tableau" "$GASH_COFFRE/tableau" >/dev/null
    then
        echo "Les deux tableaux sont différents du tableau original !"
        return 1
    fi

    # _local_check that the date of the tableau in the "coffre" is fine
    local D1
    D1=$(GET_MTIME "$GASH_COFFRE/tableau" | sha1sum | cut -c 1-40)
    local D2
    D2=$(cat "$GASH_TMP/date_tableau")

    if [ "$D1" != "$D2" ]
    then
        echo "Le tableau du donjon est toujours l'original !"
        return 1
    fi

    rm -f "$GASH_TMP/date_tableau"

    return 0
}


if _local_check
then
    unset -f _local_check
    true
else
    unset -f _local_check
    find "$GASH_HOME" -iname "tableau" -print0 | xargs -0 rm -rf
    false
fi

