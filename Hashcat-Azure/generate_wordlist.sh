#!/bin/bash

# This script accepts the domain name of a client as input to generate a wordlist based on strings found on their main website.

while getopts "t:" opt; do
 case $opt in
   t) target=$OPTARG;;
 esac
done
if [[ $target == "" ]]; then
  echo 'Target (-t) not given.' >&2
  echo 'For example: ordina.nl' >&2
  exit 1
fi

# Checks for installed packages
function StartUpChecks() {
  if ! command -v cewl &> /dev/null; then
    sudo apt install cewl
  fi
  if ! command -v go &> /dev/null; then
    wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
    sudo tar -zxvf go1.17.linux-amd64.tar.gz -C /usr/local/
    export PATH=/root/go/bin:/usr/local/go/bin:${PATH}
    rm go1.17.linux-amd64.tar.gz
  fi
  if ! command -v httpx &> /dev/null; then
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  fi
}

# Gets the full url of a target, this is required for cewl to work.
function GetFullURL() {
  url=$(echo "$target" | httpx -fr -silent -json | jq -r '."final-url"')
}

# Uses cewl to extract strings from targets website. A depth of 3 will be used and all unique words longer than 4 characters will be written to /opt/wordlists/$target.txt.
function GenerateWordlists() {
  cewl -d 3 -m 4 -w /opt/wordlists/$target.txt $url
}
StartUpChecks
GetFullURL
GenerateWordlists
