source config.sh


echo -n "" > ips.txt
for id in $(
    aws ec2 describe-instances  --query "Reservations[].Instances[].InstanceId" --output text
);
do
    echo -n "INSTANCE_ID=" > id.txt
    echo $id >> id.txt
    bash functions.sh ip
done

while IFS='/n' read -r ip; do
    echo "Connecting to $ip"
    byobu new-window -n $ip &&
    sleep 1
    byobu send-keys "scp -o StrictHostKeyChecking=no ./setup_sceduler.sh ubuntu@$ip:./setup_sceduler.sh" C-m &&
    byobu send-keys "scp -o StrictHostKeyChecking=no ./setup_worker.sh ubuntu@$ip:./setup_worker.sh" C-m &&
    byobu send-keys "scp -o StrictHostKeyChecking=no ./setup_general.sh ubuntu@$ip:./setup_general.sh" C-m &&
    byobu send-keys "scp -o StrictHostKeyChecking=no ./jupyter_notebook_config.py ubuntu@$ip:./jupyter_notebook_config.py" C-m &&
    byobu send-keys "scp -o StrictHostKeyChecking=no ./ips.txt ubuntu@$ip:./ips.txt" C-m &&
    byobu send-keys "scp -o StrictHostKeyChecking=no ./config.sh ubuntu@$ip:./config.sh" C-m &&
    byobu send-keys "ssh -o StrictHostKeyChecking=no ubuntu@$ip" C-m &&
done < ips.txt

byobu select-window -t 0
echo "All connections established. Waiting 1 sec"
sleep 1

sced=$(head -n 1 ips.txt)
echo "Establishing tunnel to jupyter-notebook and dask-dashboard on scheduler at $sced"
byobu new-window -n "tunnel"
byobu send-keys "ssh -o StrictHostKeyChecking=no ubuntu@$sced -L 8000:localhost:8888 -L 8001:localhost:8787" C-m

echo "Setting up instances."
byobu select-window -t 1
sleep 1
byobu send-keys "source setup_sceduler.sh" C-m
sleep 1
byobu select-window -t 2
sleep 1
byobu send-keys "source setup_worker.sh" C-m
sleep 1
byobu select-window -t 3
sleep 1
byobu send-keys "source setup_worker.sh" C-m
sleep 1
byobu select-window -t 4
sleep 1
byobu send-keys "source setup_worker.sh" C-m
sleep 1
byobu select-window -t 5
sleep 1
byobu send-keys "source setup_worker.sh" C-m
sleep 1
byobu select-window -t 0
sleep 1
echo "Set up startet on all instances."
