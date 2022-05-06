#!/bin/bash
while getopts "t:" opt; do
 case $opt in
   t) target=$OPTARG;;
 esac
done
if [[ $target == "" ]]; then
  echo 'Target (-t) not given.' >&2
  exit 1
fi
function StartUpChecks() {
  if ! command -v cewl &> /dev/null; then
    sudo apt install cewl
  fi
  if ! command -v go &> /dev/null; then
    wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
    sudo tar -zxvf go1.17.linux-amd64.tar.gz -C /usr/local/
    export PATH=$HOME/go/bin:${PATH}
    rm go1.17.linux-amd64.tar.gz
  fi
  if ! command -v httpx &> /dev/null; then
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  fi
}

function GetFullURL() {
  url=$(echo "$target" | httpx -fr -silent -json | jq -r '."final-url"')
}

function GenerateWordlists() {
  cewl -d 3 -m 4 -w /opt/wordlists/$target.txt $url
}
StartUpChecks
GetFullURL
GenerateWordlists
