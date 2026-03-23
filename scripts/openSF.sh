#!/bin/bash

RED=`tput setaf 1`
GREEN=`tput setaf 2`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
BLACK_BR=`tput setab 0`
RESET=`tput sgr0`
FILE=sandboxes.json

verifyJQ(){
    if ! command -v jq &> /dev/null
    then
        echoRed "jq is not installed and is required. 'brew install jq' if on MacOS and you have Homebrew installed"
        exit
    #else
        #echoGreen "Found jq"
    fi
}

verifySFDX(){
    if ! command -v sfdx &> /dev/null
    then
        echoRed "sf cli is not installed and is required. Check 'https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm' for instructions"
        exit
    #else
        #echoGreen "Found sfdx"
    fi
}

echoRed() {
  echo "${RED}$1${RESET}"
}
echoGreen() {
  echo "${GREEN}$1${RESET}"
}
echoBlue() {
  echo "${BLUE}$1${RESET}"
}
spin()
{
  spinner="/|\\-/|\\-"
  while :
  do
    for i in `seq 0 7`
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 0.3
    done
  done
}

checkForOrgList() {
    if [ -f "$FILE" ]; then
        echo ""
        echo "${GREEN}Using cached ORG list${RESET}"
        echo ""
    else
        fetchOrgList
    fi
}

fetchOrgList() {
    # Start the Spinner:
    spin &
    # Make a note of its Process ID (PID):
    SPIN_PID=$!
    disown

    echo "${GREEN}Fetching List of Authorized ORG's${RESET}.. "
    echo ""
    sf org list --json > "$FILE"
    kill -9 $SPIN_PID
}

doAuth() {
    sf org login web --instance-url $1 --alias $2
}

authorizeOrg() {
    while [[ -z "$org_alias" ]] ; do 
        read -p "What would you like as an alias? " org_alias
    done
    echo "Your alias is $org_alias"
    PS3="Select Environment: "
    options=("Production" "Sandbox" "Custom URL" "Cancel")
    select opt in "${options[@]}"
    do
        case $opt in
            "Cancel")
                break
                ;;
            "Production")
                doAuth "https://login.salesforce.com" $org_alias
                break
                ;;
            "Sandbox")
                doAuth "https://test.salesforce.com" $org_alias
                break
                ;;
            "Custom URL")
                read -p "Enter the My Domain URL: " org_url
                if [[ "$org_url" != https://* ]]; then
                    org_url="https://$org_url"
                fi
                doAuth $org_url $org_alias
                break
                ;;
            *) echo "invalid option $opt";;
        esac
    done
}

removeOrg(){
    sf org logout
    fetchOrgList
}

displayMenu() {
    buildBuckets
    echo ""
    PS3=$'\n'"${BLUE}Which ORG would you like to open?"$'\n'"(${RESET} q ${BLUE}to ${RED}QUIT${RESET},${RESET} r ${BLUE}to ${MAGENTA}REFRESH${RESET}, ${RESET} a ${BLUE}to ${GREEN}AUTH NEW ORG${RESET}${BLUE} ${RESET}, d to REMOVE AN ORG )"
    select opt in "${BUCKETS[@]}"
    do
        choice $opt $REPLY
        break
    done
}

choice () {
    if [ "$1" == "q" ]; then
        exit 0
    fi
    if [ "$1" == "r" ]; then
        fetchOrgList
        displayMenu
    fi
    if [ "$1" == "a" ]; then
        authorizeOrg
        fetchOrgList
        displayMenu
    fi
    if [ "$1" == "d" ]; then
        removeOrg
    fi
    if [[ " ${BUCKETS[*]} " =~ " $1 " ]]; then
        echoGreen "Opening $1"
        sf org open -o $1
    fi
    if [[ ! " ${BUCKETS[*]} " =~ " $1 " ]]; then
        echoRed "Invalid Selection!"
        displayMenu
    fi
}

buildBuckets() {
    BUCKETS=()
    while IFS= read -r entry; do
        BUCKETS+=("$entry")
    done < <(jq -r '.result.nonScratchOrgs' $FILE | jq -r '.[].alias')
    while IFS= read -r entry; do
        BUCKETS+=("$entry")
    done < <(jq -r '.result.scratchOrgs' $FILE | jq -r '.[].alias')
}

#verify dependencies
verifyJQ
verifySFDX

#check for list of ORG's and retrieve if missing
checkForOrgList
#Finally Display the Menu
displayMenu
