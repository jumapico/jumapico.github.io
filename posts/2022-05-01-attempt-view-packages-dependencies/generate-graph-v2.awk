BEGIN {
    print "digraph dependencies {"
    print "  fontname=\"Helvetica,Arial,sans-serif\""
    print "  node [fontname=\"Helvetica,Arial,sans-serif\"]"
    print "  edge [fontname=\"Helvetica,Arial,sans-serif\"]"
    print "  rankdir=\"LR\""
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
