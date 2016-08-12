cd $(dirname $0)
. ./set_graphicsmagick.sh
"$GM" convert "$1" -trim "$1"
