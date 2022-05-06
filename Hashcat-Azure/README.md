# Hashcat Azure

[Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Framondunker%2Fhashcat-azure%2Fmain%2FHashcat-Azure%2Fazuredeploy.json)

[Visualize](http://armviz.io/#?load=https%3A%2F%2Fraw.githubusercontent.com%2Framondunker%2Fhashcat-azure%2Fmain%2FHashcat-Azure%2Fazuredeploy.json)


This tool is made to automatically setup a hash cracking VM in Azure.

## Usage
Once deployed, use your VPN to connect to the box via SSH or the webinterface.

## How it works
The deployment will create a Debian 10 instance on an Azure NCasT4_v3-series virtual machine. The deployment process executes a custom script to install all packages required to start cracking. The hardening of the server has also been taken into consideration.


# To do
* Extensive tests and codereview
