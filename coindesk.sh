#!/bin/bash
# Credit to David Walsh for the original script <https://davidwalsh.name/bitcoin>
# The improved version of David's script doesn't go back to prompt. It keeps refreshing the prices every 5 seconds.
# Prices are in USD, EUR & GBP (in real time)
# curl must be installed in terminal
clear
echo "Coinbase LTC SELL PRICE: "

while [ 1 ] 
do
curl -s https://api.coinbase.com/v2/prices/LTC-USD/sell |  python -c "import json, sys; bitcoin=json.load(sys.stdin); litecoin=bitcoin['data']; print litecoin['amount']"
sleep 5
done
