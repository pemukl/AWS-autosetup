echo "Setup Sceduler started."

source dask_env/bin/activate

echo "Launching General Setup in Background."
byobu-ctrl-a screen
byobu new-session -d -s "scheduler"
byobu send-keys "source ./setup_general.sh" C-m

pip install requests
pip install "click<=7,<8"

jupyter notebook --generate-config -y
cp ./jupyter_notebook_config.py ./.jupyter/jupyter_notebook_config.py


byobu new-window -t "scheduler":1 -n "jupyter"
byobu send-keys "jupyter notebook --port=8888" C-m
byobu new-window -t "scheduler":2 -n "dask"
byobu send-keys "dask-scheduler --host 0.0.0.0" C-m
byobu select-window -t "scheduler":0

byobu attach-session