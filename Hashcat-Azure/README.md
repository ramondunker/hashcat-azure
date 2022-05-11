# Hashcat Azure

[Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Framondunker%2Fhashcat-azure%2Fmain%2FHashcat-Azure%2Fazuredeploy.json)


Deze tool zet automatisch een Azure VM op uit de NCasT4_v3-series. Deze wordt ingesteld als hashcracker welke via SSH en de webinterface te bereiken is.

## Gebruik
Wanneer de VM geïnstalleerd is kan vanaf het aangegeven IP adres verbonden worden met poort 443 (HTTPS) of 22 (SSH).

## Hoe werkt het?
Deze deployment maakt een Debian 10 instantie op een Azure NCasT4_v3-series virtuele machine. De deployment voert automatisch een custom installatie uit van alle packages die vereist zijn om te starten met hash cracking. De hardening van het systeem wordt ook ingesteld.


# To do
* Code review
