echo "--- START OF Controller ---"
date
echo "--- END OF Controller ---"

LIST_OF_SERVER="cisco@172.20.98.241 cisco@172.20.98.242 soltb1-compute1 soltb1-compute2 soltb1-compute3 soltb1-compute4"

for each in $LIST_OF_SERVER
do
    echo ""
    echo "--- START OF $each ---"
    ssh -t $each '
    date
    '
    echo "--- END OF $each ---"
done


