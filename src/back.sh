
##
# Check if a manga's chapter exists
#
# @returns {boolean}
#
function isExistingMangaOrChapter {
  if [ -n `getScanSourcePath 1` ]; then
    echo "1"
  else
    echo "0"
  fi
}

##
# Check if a website is UP - And btw if the user is connected to the internet
# by running a CURL command. The method accepts both 200 and 302 HHTP codes as
# valid results.
#
# @params  {string}  $1  Website's URL
#
# @returns {boolean}
#
function isWebsiteUp {
  local HTTP_STATUS=`curl -sI $1 | grep "HTTP" | cut -d ' ' -f 2`
  if (($HTTP_STATUS == 200)) || (($HTTP_STATUS == 302)); then
    echo "1"
  else
    echo "0"
  fi
}

##
# Check if the pasted URL is a valid Mangafox's one
#
# @params  {string}  $1  Website's URL
#
# @returns {boolean}
#
function isValidMangafoxUrl {
  if [ -n `echo $1 | grep "$MANGAFOX_URL/manga/"` ]; then
    echo "1"
  else
    echo "0"
  fi
}

##
# Display a warning if the user is trying to execute the script outside
# it's user folder
#
function checkApplicationPath {
  local USER_HOME=`whoami`
  if [ -z `echo $APP_PATH | grep "$USER_HOME"` ]; then
    displayWarningLine "You should not run this app. from outside your user's home folder!"
  fi
}

##
# Generate a 80 characters's long progress bar with a specified percentage
#
# @params  {integer}  $1  A percentage value, between 0 and 100
#
# @returns {string}  ASCII code of the progress bar
#
function generateProgressBar {
  local percent="$1"
  local todoChar=""
  local progressBar=""
  local progressChar="#"
  local progressToDo="                                                                      "
  local progressSize=`echo "${#progressToDo}"`

  # Number of pattern character to draw to reflect the real progress
  local progressRelative=`calculate $percent/100`
  local progressCharNumber=`calculate $progressSize*$progressRelative`
  local progressCharNumber=`echo $progressCharNumber | cut -d "." -f 1`
  local todoCharNumber=$(($progressSize - $progressCharNumber))

  # Generation of the progress
  for n in $(eval echo "{1..$progressCharNumber}")
  do
    progressBar="${progressBar}${progressChar}"
  done

  # Generation of the progress
  for n in $(eval echo "{1..$todoCharNumber}")
  do
    todoChar="${todoChar} "
  done

  if [ $percent -lt 2 ]; then
    progressBar=""
  fi

  if [ $percent -gt 98 ]; then
    todoChar=""
  else
    if [ $percent -lt 10 ]; then
      percent="  $percent"
    else
      percent=" $percent"
    fi
  fi

  echo -e "[${BLU}${progressBar}${OFF}${todoChar}] ${percent} %"
}

##
# Make a basic calcul using awk command
#
# @params {string} $* A calcul to do, like '3*4'
#
# @returns {float}
#
function calculate {
  awk "BEGIN{print $*}"
}

##
# Set chapter's information (name, number, ...)
#
function setChapterData {
  local MangaTitle=`echo $MANGA_CHAPTER_URL | cut -d "/" -f 5`
  local HAS_VOLUME=`echo $MANGA_CHAPTER_URL | cut -d "/" -f 7 | grep -v "html"`

  displayTitle "Step 2. Get Chapter's information from pasted URL"

  # Manga name
  if [ -n "$MangaTitle" ]; then
    MANGA_TITLE="$MangaTitle"
  else
    displayErrorLine " Can't retrieve the manga title"
    displayFooter
    exit 0
  fi

  if [ -z "$HAS_VOLUME" ]; then

    echo "NO VOLUME FOR THIS MANGA"
    local MangaChapterNumber=`echo $MANGA_CHAPTER_URL | cut -d "/" -f 6`

    # Chapter number
    if [ -n "$2" ]; then
      MANGA_CHAPTER_NUMBER="$MangaChapterNumber"
    else
      displayErrorLine " Can't retrieve the chapter number"
      displayFooter
      exit 0
    fi

  else

    local MangaVolumeNumber=`echo $MANGA_CHAPTER_URL | cut -d "/" -f 6`
    local MangaChapterNumber=`echo $MANGA_CHAPTER_URL | cut -d "/" -f 7`

    # Volume number
    if [ -n "$MangaVolumeNumber" ]; then
      MANGA_VOLUME_NUMBER="$MangaVolumeNumber"
    else
      displayErrorLine " Can't retrieve the volume number"
      displayFooter
      exit 0
    fi
    # Chapter number
    if [ -n "$MangaChapterNumber" ]; then
      MANGA_CHAPTER_NUMBER="$MangaChapterNumber"
    else
      displayErrorLine " Can't retrieve the Chapter number"
      displayFooter
      exit 0
    fi

  fi

  # Manga file path
  MANGA_CHAPTER_PATH="${APP_PATH}/library/${MANGA_TITLE}"
  if [ -n "$MANGA_VOLUME_NUMBER" ]; then
    MANGA_CHAPTER_PATH="$MANGA_CHAPTER_PATH/${MANGA_VOLUME_NUMBER}"
  fi
  MANGA_CHAPTER_PATH="$MANGA_CHAPTER_PATH/${MANGA_CHAPTER_NUMBER}.html"

  displaySuccessLine " OK"
}

##
# Create application's folder if they does not exist yet
#
function setupFoldersToStoreData {
  # Create the directory that will contains manga if necessary
  if [ ! -d "$APP_PATH/library" ]; then
    mkdir "$APP_PATH/library"
  fi

  # Create a folder for the manga if necessary
  if [ ! -d "$APP_PATH/library/${MANGA_TITLE}" ]; then
    mkdir "$APP_PATH/library/${MANGA_TITLE}"
  fi

  # Create a folder for the volume if specified and neccessary
  if [ ! -z "${MANGA_VOLUME_NUMBER}" ]; then
    if [ ! -d "$APP_PATH/library/${MANGA_TITLE}/${MANGA_VOLUME_NUMBER}" ]; then
      mkdir "$APP_PATH/library/${MANGA_TITLE}/${MANGA_VOLUME_NUMBER}"
    fi
  fi
}

##
# Display an error and stop the app. if Mangafox's website is DOWN
#
function checkIfMangafoxIsUp {
  displayTitle "Step 3. Check if \"$MANGAFOX_URL\" is UP"

  if ((`isWebsiteUp "$MANGAFOX_URL"` == 1)); then
    displaySuccessLine " OK"
  else
    displayErrorLine " $MANGAFOX_URL is down!"
    displayFooter
    exit 0
  fi
}

##
# Display an error an stop the app. if pasted URL is not valid
#
# @params {string}  $1  A website's URL
#
function checkPastedUrl {
  if [ "$#" -lt 1 ]; then
    displayErrorLine "Missing argument for checkPastedUrl()"
    displayFooter
    exit 0
  fi

  displayTitle "Step 1. Check pasted URL"

  if ((`isValidMangafoxUrl "$1"` == 0)); then
    displayErrorLine " Invalid Mangafox URL!"
    displayUsage
    displayFooter
    exit 0
  fi

  if ((`isWebsiteUp $1` == 0)); then
    displayErrorLine " This URL does not refer to an existing manga or chapter"
    displayUsage
    displayFooter
    exit 0
  fi

  MANGA_CHAPTER_URL="$1"
  displaySuccessLine " OK"
}

##
# Check if the chapter's URL exist
#
# @params {string}  $1  A chapter's URL
#
function checkIfTheChapterExist {
  displayTitle "Step 4. Verify the existence of the chapter"

  if ((`isExistingMangaOrChapter` == 0)); then
    local CHAPTER_URL=`buildChapterUrl`
    displayErrorLine " The manga, volume, or Chapter doesn't exist or the URL you entered"
    displayErrorLine " is invalid. Please verify the it:"
    echo ""
    displayErrorLine " \033[1m$CHAPTER_URL\033[0m"
    displayFooter
    exit 0
  else
    MANGA_CHAPTER_URL="$1"
  fi

  displaySuccessLine " OK"
}

##
# Get the total number of scans (images) for the chapter
#
function getChapterTotalScansNumber {
  local CHAPTER_URL=`buildChapterUrl`
  local CHAPTER_CONTENT=`curl --compressed -sL $CHAPTER_URL/1.html`
  for n in {1..500}
  do
    local SCAN_NUMBER=`echo $CHAPTER_CONTENT | grep "<option value=\"$n\""`
    if [ -z "$SCAN_NUMBER" ]; then
      MANGA_CHAPTER_SCANS="$(($n - 1))"
      break
    fi
  done
}

##
# Build the local URL of the scrapped manga, to let the user copy/paste it to
# it's favorite navigator and enjoy the fun! #kazooo
#
function buildChapterUrl {
  local PAGE_URL="${MANGAFOX_URL}/manga/${MANGA_TITLE}"
  if [ -n "$MANGA_VOLUME_NUMBER" ]; then
    PAGE_URL="${PAGE_URL}/${MANGA_VOLUME_NUMBER}"
  fi
  echo "${PAGE_URL}/${MANGA_CHAPTER_NUMBER}"
}

##
# Get image/scan source path
#
# @params  {integer}  $1  The scan's number
#
# returns {string}
#
function getScanSourcePath {
  local CHAPTER_URL="$(buildChapterUrl)"
  local SCAN_URL=`curl --compressed -sL $CHAPTER_URL/$1.html | grep 'id="image"' | tr -s ' ' | cut -d ' ' -f 2 | cut -d '"' -f 2`
  echo "$SCAN_URL"
}

##
# Get manga cover source path
#
# returns {string}
#
function getCoverSourcePath {
  local CHAPTER_URL="${MANGAFOX_URL}/manga/${MANGA_TITLE}"
  local COVER_URL=`curl --compressed -sL $CHAPTER_URL | grep 'width="200"' | tr -s ' ' | cut -d '"' -f 4 | cut -d "?" -f 1`

  echo "$COVER_URL"
}


##
# Check if the user want's to display the help/usage, by checking every
# environnement variable
#
function displayUsageIfRequestedOrIfNoArguments {
  # No env. variable
  if [ $# -eq 0 ]; then
    displayUsage
    displayFooter
    exit 0
  fi

  # One env. variable is equal to "-h" or "--help"
  variables=(`echo $@`)
  for env in "${variables[@]}"
  do
    if [ "$env" = "-h" ] || [ "$env" = "--help" ]; then
      displayUsage
      displayFooter
      exit 0
    fi
  done
}

##
# Create a HTML file that contains the chapiter's scans
#
function buildChapterFile {
  displayTitle "Step 5. Build the chapter's HTML page"

  # Create the Chapter file by copying a template to the destination dir.
  cp "$APP_PATH/src/templates/header.html" $MANGA_CHAPTER_PATH

  # Add application's version to page title
  sed -i.bak "s|APP_VERSION|${APP_VERSION}|g" $MANGA_CHAPTER_PATH

  # Setup a JS constant for the total number of pages
  sed -i.bak "s|987654321|${MANGA_CHAPTER_SCANS}|g" $MANGA_CHAPTER_PATH
  rm $MANGA_CHAPTER_PATH.bak

  # Setup manga informations as first "scan"
  local FORMATED_TITLE="$(echo $MANGA_TITLE | sed 's/_/ /g')"
  local COVER_IMAGE=`getCoverSourcePath`
  local VOLUME_NB=`echo $MANGA_VOLUME_NUMBER | sed 's/v//'`
  local CHAPTER_NB=`echo $MANGA_CHAPTER_NUMBER | sed 's/c//'`
  echo "    <div class=\"scan\" id=\"scan-0\">" >> $MANGA_CHAPTER_PATH
  echo "      <h1 class=\"title\">$FORMATED_TITLE</h1>" >> $MANGA_CHAPTER_PATH
  echo "      <img src=\"$COVER_IMAGE\" id=\"cover\" />" >> $MANGA_CHAPTER_PATH
  if [ -n "$MANGA_VOLUME_NUMBER" ]; then
    echo "      <h3>Volume ${VOLUME_NB}<br />Chapter ${CHAPTER_NB}</h3>" >> $MANGA_CHAPTER_PATH
  else
    echo "      <h3>Chapter ${CHAPTER_NB}</h3>" >> $MANGA_CHAPTER_PATH
  fi
  echo "    </div>" >> $MANGA_CHAPTER_PATH

  # Add scans to the main contant
  #MANGA_CHAPTER_SCANS=2 # for tests purpose!
  for n in $(eval echo "{1..$MANGA_CHAPTER_SCANS}")
  do
    # Display progress bar
    local decimal=`calculate $n/$MANGA_CHAPTER_SCANS`
    local percentage=`calculate $decimal*100`
    local percentageInteger=`echo $percentage | cut -d "." -f 1`
    local progress=`generateProgressBar $percentageInteger`
    echo -ne " $progress\r"

    # Add the main content to the Chapter file
    local SCAN_URL=`getScanSourcePath $n`
    echo "    <div class=\"scan\" id=\"scan-$n\">" >> $MANGA_CHAPTER_PATH
    echo "      <img src=\"$SCAN_URL\" />" >> $MANGA_CHAPTER_PATH
    echo "    </div>" >> $MANGA_CHAPTER_PATH
  done

  # Add a "The End" final scan
  local MANGA_CHAPTER_SCANS2=$(($MANGA_CHAPTER_SCANS + 1))
  echo "    <div class=\"scan last\" id=\"scan-$MANGA_CHAPTER_SCANS2\">" >> $MANGA_CHAPTER_PATH
  echo "      <h2>- THE END -</h2>" >> $MANGA_CHAPTER_PATH
  echo "    </div>" >> $MANGA_CHAPTER_PATH

  # Add the footer content to the file
  cat "$APP_PATH/src/templates/footer.html" >> $MANGA_CHAPTER_PATH

  echo -ne '\n'
}
