cd $(dirname $0)
. ./set_graphicsmagick.sh
"$GM" composite -compose difference "$1" "$2" "$3"
"$GM" compare -metric MAE "$1" "$2"
