#!/bin/bash
if ! [ -x "$(command -v nmap)" ]; then
  echo '[-] nmap is not installed or not in path.' >&2
  exit 1
fi
if ! [ -x "$(command -v amass)" ]; then
  echo '[-] amass is not installed or not in path.' >&2
  exit 1
fi
if ! [ -x "$(command -v chromium)" ]; then
  echo '[-] chromium-browser is not installed, aquatone performance might suffer.' >&2
fi


if [ $# -eq 0 ]
  then
    echo "Please supply a domain name (./autorecon example.com)"
  else
    echo "[+] Proxy setting on localhost:8080 hardcoded. Remove if you don't want to use a proxy"
    mkdir output/$1
    cd output/$1
    echo "[+] Starting amass DNS enumeration..."
    amass enum -active -brute -o $1.domains -d $1
    echo "[+] Enumerated domains saved to output/$1.domains"
    echo "[+] Running nmap"
    mkdir nmap_output
    nmap -iL $1.domains -Pn -T4 -oA nmap_output/$1
    echo "Nmap output saved out output/nmap_output/"
    echo "[+] Running aquatone"
    mkdir aquatone_output
    cat nmap_output/$1.xml | ../../bin/aquatone -nmap -proxy http://localhost:8080 -out aquatone_output/
    echo "[+] Aquatone output saved to output/aquatone_output"
    read -p "Open aquatone report (requires google-chrome)? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if ! [ -x "$(command -v google-chrome)" ]; then
            echo '[-] google chrome is not installed or not in path.' >&2
            exit 1
        fi
        google-chrome aquatone_output/aquatone_report.html
    fi
    echo "[+] All done!"
fi
