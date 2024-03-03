tmp_dir="/tmp/cliphist"
rm -rf "$tmp_dir"

if [[ -n "$1" ]]; then
    if [ "$ROFI_RETV" == "2" ]; then
        echo $1 | wl-copy -n
        echo $1 | wl-copy -p -n
    fi
    cliphist decode <<<"$1" | wl-copy -n
    cliphist decode <<<"$1" | wl-copy -p -n
    exit
fi

mkdir -p "$tmp_dir"

read -r -d '' prog <<EOF
/^[0-9]+\s<meta http-equiv=/ { next }
match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
    system("echo " grp[1] "\\\\\t | cliphist decode >$tmp_dir/"grp[1]"."grp[3])
    print \$0"\0icon\x1f$tmp_dir/"grp[1]"."grp[3]
    next
}
1
EOF
cliphist list | gawk "$prog"
