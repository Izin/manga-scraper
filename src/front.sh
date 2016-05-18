
# Colors
BLU='\033[0;34m';
GRE='\033[0;32m';
ORA='\033[0;33m';
RED='\033[0;31m';
OFF='\033[0m';

##
# Show the application's header
#
function displayHeader {
  clear
  echo -e ""
  echo "┌──────────────────────────────────────────────────────────────────────────────┐"
  echo -e "│${GRE}    ███╗   ███╗       █████╗       ███╗   ██╗       ██████╗        █████╗     ${OFF}│"
  echo -e "│${GRE}    ████╗ ████║      ██╔══██╗      ████╗  ██║      ██╔════╝       ██╔══██╗    ${OFF}│"
  echo -e "│${GRE}    ██╔████╔██║      ███████║      ██╔██╗ ██║      ██║  ███╗      ███████║    ${OFF}│"
  echo -e "│${GRE}    ██║╚██╔╝██║      ██╔══██║      ██║╚██╗██║      ██║   ██║      ██╔══██║    ${OFF}│"
  echo -e "│${GRE}    ██║ ╚═╝ ██║      ██║  ██║      ██║ ╚████║      ╚██████╔╝      ██║  ██║    ${OFF}│"
  echo -e "│${GRE}    ╚═╝     ╚═╝      ╚═╝  ╚═╝      ╚═╝  ╚═══╝       ╚═════╝       ╚═╝  ╚═╝    ${OFF}│"
  echo -e "│${GRE}                                                                              ${OFF}│"
  echo -e "│${GRE}    ███████╗   ██████╗  ██████╗    █████╗   ██████╗   ███████╗  ██████╗       ${OFF}│"
  echo -e "│${GRE}    ██╔════╝  ██╔════╝  ██╔══██╗  ██╔══██╗  ██╔══██╗  ██╔════╝  ██╔══██╗      ${OFF}│"
  echo -e "│${GRE}    ███████╗  ██║       ██████╔╝  ███████║  ██████╔╝  █████╗    ██████╔╝      ${OFF}│"
  echo -e "│${GRE}    ╚════██║  ██║       ██╔══██╗  ██╔══██║  ██╔═══╝   ██╔══╝    ██╔══██╗      ${OFF}│"
  echo -e "│${GRE}    ███████║  ╚██████╗  ██║  ██║  ██║  ██║  ██║       ███████╗  ██║  ██║      ${OFF}│"
  echo -e "│${GRE}    ╚══════╝   ╚═════╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝       ╚══════╝  ╚═╝  ╚═╝      ${OFF}│"
  echo "├─────────────────────────────────────────────────────────────────┬────────────┤"
  echo -e "│ ${BLU}Automatic HTML page generator for reading a manga from Mangafox${OFF} │   ${ORA}v${APP_VERSION}${OFF}   │"
  echo "└─────────────────────────────────────────────────────────────────┴────────────┘"
}

##
# Show the application's footer
#
function displayFooter {
  echo ""
  echo "─────────────────────────────────┤  E N D  ├────────────────────────────────────"
  echo ""
}

##
# Show the application's usage content
#
function displayUsage {
  displayTitle "How to use"
  displayInfoLine " 1. Go to the first chapter's page of the manga you want to read"
  displayInfoLine "    (in Mangafox obviously)"
  echo ""
  displayInfoLine " 2. Re-launch this app by passing the chapter's URL as argument, like this:"
  displayInfoLine "    ┌ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ┐"
  echo -e "    ${BLU}|${OFF} cd manga-scraper                                                      ${BLU}|${OFF}"
  echo -e "    ${BLU}|${OFF} bash scrap \"http://mangafox.me/manga/tower_of_god/v01/c7/12.html\"     ${BLU}|${OFF}"
  displayInfoLine "    └ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ┘"
  echo ""
  displayInfoLine " 3. When this script has finished working, copy/paste the displayed URL"
  displayInfoLine "    in your favorite navigator"
  echo ""
  displayInfoLine " 4. Enjoy :) !"
}

##
# Show a title
# @params  {string}  $1  Title text
#
function displayTitle {
  echo ""
  echo " $1"
  echo " ──────────────────────────────────────────────────────────────────────────────"
}

##
# Show an information line
#
# @params  {string}  $1  A text string
#
function displayInfoLine {
  echo -e "${BLU}${1}${OFF}"
}

##
# Show a warning line
#
# @params  {string}  $1  A text string
#
function displayWarningLine {
  echo -e "${ORA}${1}${OFF}"
}

##
# Show a success line
#
# @params  {string}  $1  A text string
#
function displaySuccessLine {
  echo -e "${GRE}${1}${OFF}"
}

##
# Show an error line
#
# @params  {string}  $1  A text string
#
function displayErrorLine {
  echo -e "${RED}${1}${OFF}"
}

##
# Show a bloc that contains the final URL to read the wrapped chapter
#
function displayBuiltChapterPath {
  echo ""
  echo "┌──────────────────────────────────────────────────────────────────────────────┐"
  echo "│                              chapter is ready!                               │"
  echo "└──────────────────────────────────────────────────────────────────────────────┘"
  echo ""
  echo -e " ${ORA}─>${OFF} ${GRE}$MANGA_CHAPTER_PATH${OFF}"
  echo ""
}
