#!/bin/sh

err() { echo "Usage:
    tag [OPTIONS] file
Options:
    -I: dont hide the image
" && exit 1 ;
}

    # -t: song/chapter title
    # -A: album/book title
    # -n: track/chapter number
    # -N: total number of tracks/chapters
    # -d: year of publication
    # -g: genre
    # -c: comment

while getopts "I:" o; do case "${o}" in
    I) donthide="yep" ;;
#     a) artist="${OPTARG}" ;;
#     t) title="${OPTARG}" ;;
#     A) album="${OPTARG}" ;;
#     n) track="${OPTARG}" ;;
#     N) total="${OPTARG}" ;;
#     d) date="${OPTARG}" ;;
#     g) genre="${OPTARG}" ;;
#     c) comment="${OPTARG}" ;;
    *) printf "Invalid option: -%s\\n" "$OPTARG" && err ;;
esac done

shift $((OPTIND - 1))
file="$1"

temp="$(mktemp)"
trap 'rm -f $temp' HUP INT QUIT TERM EXIT

[ ! -f "$file" ] && echo 'Provide file to tag.' && exit 1

vorbiscomment -l "$file" -c "$temp"

if [ ! -n "$donthide" ]; then
    image="$(grep "METADATA_BLOCK_PICTURE" $temp)"
    sed -i -e '/METADATA_BLOCK_PICTURE/d' $temp
fi

grep "language=" $temp || echo "language=" >> $temp
grep "artist=" $temp || echo "artist=" >> $temp
grep "title=" $temp || echo "title=" >> $temp
grep "album=" $temp || echo "album=" >> $temp
# grep "track=" $temp || echo "track=" >> $temp
# grep "total=" $temp || echo "total=" >> $temp
grep "tags=" $temp || echo "tags=" >> $temp
# grep "genre=" $temp || echo "genre=" >> $temp
grep "comment=" $temp || echo "comment=" >> $temp

$EDITOR $temp

[ -n "$image" ] && echo "$image" >> $temp
vorbiscomment -w "$file" -c "$temp"

# [ -z "$title" ] && echo 'Enter a title.' && read -r title
# [ -z "$artist" ] && echo 'Enter an artist.' && read -r artist
# [ -z "$album" ] && echo 'Enter an album.' && read -r album
# [ -z "$track" ] && echo 'Enter a track number.' && read -r track
#
# cp -f "$file" "$temp" && ffmpeg -i "$temp" -map 0 -y -codec copy \
#     -metadata title="$title" \
#     -metadata album="$album" \
#     -metadata artist="$artist" \
#     -metadata track="${track}${total:+/"$total"}" \
#     ${date:+-metadata date="$date"} \
#     ${genre:+-metadata genre="$genre"} \
#     ${comment:+-metadata comment="$comment"} "$file"
