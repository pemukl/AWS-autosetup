myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
sced=$(head -n 1 ips.txt)
echo "Setup Worker started on ${myip} with scheduler ${sced}."

source dask_env/bin/activate

echo "Launching General Setup in Background."
byobu-ctrl-a screen
byobu new-session -d -s "worker"
byobu send-keys "source ./setup_general.sh" C-m

pip install requests
pip install "click<=7,<8"


byobu new-window -t "worker":1 -n "worker"
byobu send-keys "dask-worker $sced:8786 --nprocs 4" C-m

byobu select-window -t "worker":0

byobu attach-session