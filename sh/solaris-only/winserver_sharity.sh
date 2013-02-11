#!/bin/sh

win_server=""
win_share=""
win_username=""
win_password=""
win_mount="/winserver"
sharity_cmd="/usr/local/sharity3/bin/sharity"


echo "=== Collegamento al server windows $win_server cartella di rete $win_share... ==="

# dump dei parametri
echo "=== Server: $win_server   ==="
echo "=== Share:  $win_share    ==="
echo "=== User:   $win_username ==="
echo "=== Mount:  $win_mount    ==="

# login al server
su - luca -c "$sharity_cmd login smb://$win_server/$win_share -U $win_username -P $win_password"	        #
if test $? -ne 0									        #
then											        #
    echo "=== ERRORE: impossibile fare login al server con le credenziali specificate! ==="  #
    exit 1										        #
fi											        #

# effettuo il mount
$sharity_cmd mount smb://$win_server/$win_share $win_mount
if test $? -eq 0
then
    echo "=== Cartella collegata con successo e disponibile in $win_mount! ==="
else
    echo "=== ERRORE: impossibile montare la cartella di rete ==="
    exit 2
fi