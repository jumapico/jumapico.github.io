BEGIN {
    print "digraph dependencies {\n fontname=\"Helvetica,Arial,sans-serif\"\n node [fontname=\"Helvetica,Arial,sans-serif\"]\n edge [fontname=\"Helvetica,Arial,sans-serif\"]"
    hasdeps=1
}

/^@name/ {
    if (!hasdeps)
        printf " \"%s\" ;\n", current
    current=$2
    hasdeps=0
}
/^@depend/ {
    printf " \"%s\" -> \"%s\" ;\n", current, $2
    hasdeps=1
}

END {
    print "}"
}
