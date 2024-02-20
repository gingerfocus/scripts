#!/bin/sh

err() { echo "Usage:
    tag [OPTIONS] file [template]
Options:
" && exit 1 ;
}
    #-I: dont hide the image

# while getopts "I" o; do case "${o}" in
#     I) donthide="yep" ;;
#     a) artist="${OPTARG}" ;;
#     t) title="${OPTARG}" ;;
#     A) album="${OPTARG}" ;;
#     n) track="${OPTARG}" ;;
#     N) total="${OPTARG}" ;;
#     d) date="${OPTARG}" ;;
#     g) genre="${OPTARG}" ;;
#     c) comment="${OPTARG}" ;;
#     *) printf "Invalid option: -%s\\n" "$OPTARG" && err ;;
# esac done

# shift $((OPTIND - 1))
file="$1"

temp="$(mktemp "/tmp/$1.XXXXXX")"
trap 'rm -f $temp' HUP INT QUIT TERM EXIT

[ ! -f "$file" ] && echo 'Provide file to tag.' && exit 1


vorbiscomment -l "$file" -c "$temp"

if [ ! -n "$donthide" ]; then
    image="$(grep "METADATA_BLOCK_PICTURE" "$temp")"
    sed -i -e '/METADATA_BLOCK_PICTURE/d' "$temp"
fi

[ -f "$2" ] && cat "$2" >> "$temp"

grep "language=" "$temp" || echo "language=" >> "$temp"
grep "title=" "$temp" || echo "title=" >> "$temp"
grep "artist=" "$temp" || echo "artist=" >> "$temp"
grep "album=" "$temp" || echo "album=" >> "$temp"
grep "album_artist=" "$temp" || echo "album_artist=" >> "$temp"
grep "TRACKNUMBER=" $temp || echo "TRACKNUMBER=" >> $temp
grep "total=" $temp || echo "total=" >> $temp
grep "year=" "$temp" || echo "year=" >> "$temp"
grep "tags=" "$temp"|| echo "tags=" >> "$temp"
grep "rating=" "$temp" || echo "rating=" >> "$temp"
grep "comment=" "$temp" || echo "comment=" >> "$temp"


$EDITOR "$temp"

[ -n "$image" ] && echo "$image" >> "$temp"
vorbiscomment -w "$file" -c "$temp"

rm "$temp"
